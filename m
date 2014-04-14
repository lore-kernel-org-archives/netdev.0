From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch iproute2] u32: add terminal parameter
Date: Mon, 14 Apr 2014 19:14:38 -0400
Message-ID: <534C6BDE.8020600@mojatatu.com>
References: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>	<20140411140446.6412e9dc@nehalam.linuxnetplumber.net>	<CAM_iQpVpNOJ1xiK45qXGRXgBZ2QcmwoPc7p=SOHCo=1kTwPfFQ@mail.gmail.com>	<20140411175800.08e9ffe3@nehalam.linuxnetplumber.net>	<CAM_iQpU7Ntn-yo-ez0vP2BhKe+-Vaq1w_+MQhFPHM-bbQZx2gg@mail.gmail.com>	<534926F7.10505@mojatatu.com> <CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:44961 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbaDNXOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 19:14:53 -0400
Received: by mail-oa0-f45.google.com with SMTP id eb12so9885532oac.4
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 16:14:53 -0700 (PDT)
In-Reply-To: <CAM_iQpXJnOOUbpS0WwrB7C50LGxcLhMEQPrDB84Zm-SLKVHh6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/14 17:18, Cong Wang wrote:
> On Sat, Apr 12, 2014 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> Why? The qdisc my u32 filters attached to is classless (ingress).

flowid is a filter id. I am almost certain it was a mistake on your
part to leave it out. This is why i called it an FAQ and suggested
you provide a patch to block people from leaving it out.

> Also, why this is relevant to u32 terminal?

Because if you defined a flowid you are defining it as a terminal
u32 node. You wouldnt have to complain about "???" or produce a patch
to solve a non-existent problem.
You want to add a new syntax and didnt even bother to look at the code?

>> So I agree with Stephen on the verdict on your patch.
>> We need a patch to avoid this FAQ problem since it happens
>> often i.e reject a filter that doesnt have flow/classid
>> specified. How about you provide that patch instead?
>>
>
> Even if you were right, it is too late to change, we obviously don't
> want to break existing scripts that work fine. I am pretty sure
> my script runs well without flowid.
>

I dont think it can be guaranteed to work at all if you dont specify
a flowid. You may have gotten lucky.

cheers,
jamal
