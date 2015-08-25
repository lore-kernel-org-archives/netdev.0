From: Cong Wang <cwang@twopensource.com>
Subject: Re: iproute2: Behavioural Bug?
Date: Mon, 24 Aug 2015 23:08:35 -0700
Message-ID: <CAHA+R7OWyfupqmCk69ykN7TP+sMwUyVtFNX=Mr_Q9DCXRSx6fw@mail.gmail.com>
References: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
	<20150824232229.GC5905@breakpoint.cc>
	<CAA5aLPj6Whq_U3VXx60J+b0rZFj9kucXy8H9NM9rYCTc9OPMoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:35655 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155AbbHYGIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 02:08:36 -0400
Received: by ykbi184 with SMTP id i184so145808581ykb.2
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 23:08:36 -0700 (PDT)
In-Reply-To: <CAA5aLPj6Whq_U3VXx60J+b0rZFj9kucXy8H9NM9rYCTc9OPMoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:14 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> Dear Florian,
>
> There are two filters 15:2:2 and 15:2:3 and I have deleted only
> 15:2:3, so 15:2:2 will still be there and hence this condition
> "destroy proto tp when all filters are gone" should not be applicable
> over here.
>

Florian is correct, it _does_ look like this is caused by my patch,
I guess some check in u32_destroy() isn't correct.

It's late here, I will look into this tomorrow.

Thanks for the report anyway!
