From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Tue, 15 Apr 2014 13:17:50 -0700
Message-ID: <CAM_iQpVmxmutCXMucP65UoxtPON=vJrxQ3B_jDTpMjWPycebaw@mail.gmail.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>
	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>
	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>
	<CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>
	<534926F7.10505@mojatatu.com>
	<CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>
	<534C6BDE.8020600@mojatatu.com>
	<CAM_iQpV8GeEQr+GFFy2Etct_51YhvXEBKydyH9q4NP5QbsDOnA@mail.gmail.com>
	<534D2D62.5080109@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:64071 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbaDOURv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 16:17:51 -0400
Received: by mail-oa0-f50.google.com with SMTP id i7so11558117oag.9
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 13:17:50 -0700 (PDT)
In-Reply-To: <534D2D62.5080109@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 6:00 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/14/14 21:57, Cong Wang wrote:
>
>> So essentially why u32 filters can't just do matching without bothering
>
>
> u32 is a special animal. You can actually have intermediate nodes
> which are _not_ terminal. i.e you can build a tree of hashes which
> interconnect other hashes eventually leading to terminal nodes.
>

I knew, I thought at least classid is an alternative for action, that is,
one doing classify and one doing some other action.

>
>> classid especially when they are attached to an ingress qdisc? I still
>> fail to see a reason why I have to care about classid here.
>
>
> It is more of a historical artifact with "benefits".
> Historical in that egress qdiscs with classes existed before ingress;
> so it makes sense to keep the syntax people are already familiar with.
> Benefits because infact with the right approach the flowid even at
> ingress can be used as input(look at the route classifier for example
> and association with route accounting of the source).
>

I see. The next question would be what is a reasonable classid
value for a classless qdisc? Or can we set it to some value to express
"we don't care"?

Thanks!
