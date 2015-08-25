From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: iproute2: Behavioural Bug?
Date: Tue, 25 Aug 2015 12:48:51 +0530
Message-ID: <CAA5aLPjLhLdp2QPMw-ZvNOVjsewnM3TqV4zHFfY2_HX0UOqoFg@mail.gmail.com>
References: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
	<20150824232229.GC5905@breakpoint.cc>
	<CAA5aLPj6Whq_U3VXx60J+b0rZFj9kucXy8H9NM9rYCTc9OPMoQ@mail.gmail.com>
	<CAHA+R7OWyfupqmCk69ykN7TP+sMwUyVtFNX=Mr_Q9DCXRSx6fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35117 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbHYHSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 03:18:52 -0400
Received: by obbwr7 with SMTP id wr7so134874509obb.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 00:18:51 -0700 (PDT)
In-Reply-To: <CAHA+R7OWyfupqmCk69ykN7TP+sMwUyVtFNX=Mr_Q9DCXRSx6fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well if that is the case, then just an additional information (which I
have initially mentioned though), if hashtable is 800, then behaviour
is correct i.e. deleting only a single filter but for hash tables
other than 800, the bug (if any) gets triggered.

On Tue, Aug 25, 2015 at 11:38 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Mon, Aug 24, 2015 at 10:14 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
>> Dear Florian,
>>
>> There are two filters 15:2:2 and 15:2:3 and I have deleted only
>> 15:2:3, so 15:2:2 will still be there and hence this condition
>> "destroy proto tp when all filters are gone" should not be applicable
>> over here.
>>
>
> Florian is correct, it _does_ look like this is caused by my patch,
> I guess some check in u32_destroy() isn't correct.
>
> It's late here, I will look into this tomorrow.
>
> Thanks for the report anyway!
