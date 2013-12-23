From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v4 3/8] net_sched: mirred: remove action when the
 target device is gone
Date: Mon, 23 Dec 2013 10:50:44 -0800
Message-ID: <CAM_iQpUfKcS6RDmV_p+0tEgxx6Z2Y2k9m-VxxwwpL+PB0TX96Q@mail.gmail.com>
References: <1387167311-14763-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387167311-14763-4-git-send-email-xiyou.wangcong@gmail.com>
	<52B1B1B1.2060501@mojatatu.com>
	<CAM_iQpUDZa-=H53Csg8476xOL0xP+rn85O8eB1O39-eF_Jo+uw@mail.gmail.com>
	<52B1FC6D.7040005@mojatatu.com>
	<CAM_iQpWxCShCgiBrraJ3h9qzgVU82quq0E5vmFMSEcgEwSctJQ@mail.gmail.com>
	<52B71024.3090504@mojatatu.com>
	<CAM_iQpW9kUzip+p8fCkD4wH7KbAv8aR-Fqa0iRwPYdzk8+4Tqw@mail.gmail.com>
	<52B74C3A.1050900@mojatatu.com>
	<CAM_iQpXddH4qX2+-mY5gWLU19b6zjZzKV_RvQiyTT8sJ1sq-ow@mail.gmail.com>
	<52B82F80.8070902@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:56465 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562Ab3LWSup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 13:50:45 -0500
Received: by mail-ob0-f181.google.com with SMTP id uy5so5859095obc.12
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 10:50:44 -0800 (PST)
In-Reply-To: <52B82F80.8070902@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 4:41 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/22/13 16:11, Cong Wang wrote:
>
>> NOTHING you talked about here is relevant to the policy or
>> mechanism you talked previously. Just correctness.
>>
>
> It is about _correct policy_
> If you have a packets going:
> ->A-->B-->C-->D-->E
>
> That is the policy (decided by someone/thing in user space).
> A to E are mechanisms.

Apparently you have a different definition of "policy" and "mechanism"
with me, probably with others too...

I assume you mean actions here, since we don't care about others
in this thread.

> If something goes wrong with mechanism D, you dont go deleting
> D because it is affecting other things in the graph. You have
> no clue what it would affect - and if you try to build that in
> it is not cheap for no good reason.

Since they are chained by a singly or doubly linked list in
non-shared case, where are "other things in the graph"?

Please do explain how can they be in a graph in non-shared
case, it is not obvious to me at all.

> You let the thing/person who set it know and do the deletion.
>
> You compared it to something going wrong with A(when A is netdev)
> and how we delete everything underneath. They are not the same,
> in that case, we know precisely that is the begining of the graph
> and we can unreference everything underneath.

Nope, I only want to remove A from the chain by list_del() for non-shared
case.

>
> Does that make more sense?
>

Nope, you continue to mention graph, but don't explain why there is
a graph in non-shared case. Nor I think you use "policy" or "mechanism"
correctly. :)

Jamal, please don't be abstract, just talk about actions. We DO NOT
care about others in this thread.
