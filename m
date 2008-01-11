From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Fri, 11 Jan 2008 15:37:56 -0200
Message-ID: <4787A974.7060408@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by> <47865613.1000902@trash.net>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:56230 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284AbYAKNiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 08:38:05 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0BDc3Z6016980
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 15:38:04 +0200
In-Reply-To: <47865613.1000902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:

>> --- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
>> +++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
>> @@ -161,2 +161,5 @@
>>              skb->tc_index = TC_H_MIN(res.classid);
>> +#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
>> +            skb->mark = 
>> (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
>> +#endif
>>          default:
> 
> 
> Behaviour like this shouldn't depend on compile-time options.

Also I want to move it outside of NET_CLS_ACT dependence, but unsure in 
behaviour understanding without NET_CLS_ACT.

But there are reduse code.

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by
