From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/10] Preparatory refactoring part 1.
Date: Tue, 02 Oct 2007 05:17:06 +0200
Message-ID: <4701B832.4090405@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199771607-git-send-email-bugfood-ml@fatooh.org> <4700F54A.6070408@trash.net> <47015CB4.7000102@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48445 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbXJBDRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 23:17:44 -0400
In-Reply-To: <47015CB4.7000102@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Patrick McHardy wrote:
> 
>>> -    sch->qstats.drops++;
>>
>> A line in the changelog explaining that this was increased twice
>> would have been nice.
> 
> 
> Certainly; I think I didn't realize, when you originally pointed out the
> duplicate incrementing, that it was a bug in the original version and
> not in my patch. Otherwise, I would have sent it as a separate patch.


I didn't remember that :)

> If a note in this patch will suffice, though, I'll definitely do so.


Sure, a note in the changelog will be fine.

>>> +static struct
>>> +sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
>>
>>
>>
>> What is this function needed for?
> 
> 
> It gets used in sfq_change for moving packets from the old queue into
> the new one. In this case, we don't want to modify sch->q.qlen or
> sch->qstats.backlog, since those don't actually change.
> 
>          while ((skb = sfq_q_dequeue(q)) != NULL)
>                  sfq_q_enqueue(skb, &tmp, SFQ_TAIL);


I missed that, thanks for the explanation.

