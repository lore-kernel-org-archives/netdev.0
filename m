From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when
 the target device is gone
Date: Mon, 23 Dec 2013 07:41:36 -0500
Message-ID: <52B82F80.8070902@mojatatu.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>	<52B1B1B1.2060501@mojatatu.com>	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>	<52B1FC6D.7040005@mojatatu.com>	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>	<52B71024.3090504@mojatatu.com>	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>	<52B74C3A.1050900@mojatatu.com> <CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:52173 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337Ab3LWMln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 07:41:43 -0500
Received: by mail-ig0-f170.google.com with SMTP id k19so20889433igc.1
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 04:41:42 -0800 (PST)
In-Reply-To: <CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/13 16:11, Cong Wang wrote:

> NOTHING you talked about here is relevant to the policy or
> mechanism you talked previously. Just correctness.
>

It is about _correct policy_
If you have a packets going:
->A-->B-->C-->D-->E

That is the policy (decided by someone/thing in user space).
A to E are mechanisms.
If something goes wrong with mechanism D, you dont go deleting
D because it is affecting other things in the graph. You have
no clue what it would affect - and if you try to build that in
it is not cheap for no good reason.
You let the thing/person who set it know and do the deletion.

You compared it to something going wrong with A(when A is netdev)
and how we delete everything underneath. They are not the same,
in that case, we know precisely that is the begining of the graph
and we can unreference everything underneath.

Does that make more sense?

> If removing an shared action is impossible, what about non-shared
> ones? Actually for my _own_ use case, I even don't use nor care
> about shared one...
>


Refer to above.

cheers,
jamal
