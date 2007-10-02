From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/10] Use nested compat attributes to pass parameters.
Date: Tue, 02 Oct 2007 05:21:09 +0200
Message-ID: <4701B925.5090606@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199782593-git-send-email-bugfood-ml@fatooh.org> <4700FC1E.9040309@trash.net> <47015CDA.60109@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48513 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbXJBDVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 23:21:47 -0400
In-Reply-To: <47015CDA.60109@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Patrick McHardy wrote:
> 
>>> +    nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>>> +
>>> +    RTA_PUT_U32(skb, TCA_SFQ_QUANTUM, q->quantum);
>>> +    RTA_PUT_U32(skb, TCA_SFQ_PERTURB, q->perturb_period);
>>> +    RTA_PUT_U32(skb, TCA_SFQ_LIMIT,   q->limit);
>>> +    RTA_PUT_U32(skb, TCA_SFQ_DIVISOR, q->hash_divisor);
>>> +    RTA_PUT_U32(skb, TCA_SFQ_FLOWS,   q->depth);
>>>      RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>>
>>
>>
>> This is wrong, RTA_NEST_COMPAT already dumps the structure.
> 
> 
> You mean that last line (RTA_PUT) is superfluous, right?


Exactly.

> Much thanks for the review. I'll make a new set of patches soon.


Thanks.
