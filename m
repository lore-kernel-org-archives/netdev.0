From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] Preparatory refactoring part 1.
Date: Tue, 31 Jul 2007 12:46:27 +0200
Message-ID: <46AF1303.4040909@trash.net>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548774008-git-send-email-bugfood-ml@fatooh.org> <46ADECC9.7010303@trash.net> <46AE8FD7.3010201@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58477 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746AbXGaKrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 06:47:08 -0400
In-Reply-To: <46AE8FD7.3010201@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Patrick McHardy wrote:
> 
>>> -static int
>>> -sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>>> +static void sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data
>>> *q, unsigned int end)
>>
>>
>>
>> Please make sure to break at 80 chars and to keep the style
>> in this file consistent (newline before function name).
> 
> 
> Ok. For what it's worth, though, most of the original functions in the
> file don't have a newline before the function name. Omitting the newline
>  would thus make the new/changed functions more consistent with the rest
> of the file. I don't have a preference either way, so unless you change
> your mind I'll put the newline back in..


You're right, just keep it consistent please and break at 80 chars.

>>> -    sch->qstats.backlog += skb->len;
>>
>>
>> Why not keep this instead of having both callers do it?
> 
> 
> My idea was to have all the sfq_q_* functions operate on "struct
> sfq_sched_data" and have no knowledge of the "struct Qdisc". I did this
> in order to be able to use the new functions in sfq_change() when the
> temporary sfq_sched_data doesn't have a parent Qdisc.
> 
> There's probably a better way, and I am of course open to suggestions,
> but what I did made sense to me.


Also sounds fine.
