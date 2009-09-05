From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 02/07: make cls_ops->tcf_chain() optional
Date: Sat, 05 Sep 2009 19:03:02 +0200
Message-ID: <4AA299C6.7070904@trash.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet> <20090904164113.27300.79145.sendpatchset@x2.localnet> <4AA21D9F.8090600@gmail.com> <4AA2520D.2060603@gmail.com> <4AA25A51.2040100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57700 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbZIERDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2009 13:03:01 -0400
In-Reply-To: <4AA25A51.2040100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 09/05/2009 01:57 PM:
> 
>>>> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>>>> index 09cdcdf..eaa8f43 100644
>>>> --- a/net/sched/cls_api.c
>>>> +++ b/net/sched/cls_api.c
>>>> @@ -181,6 +181,9 @@ replay:
>>>>  	if ((cops = q->ops->cl_ops) == NULL)
>>>>  		return -EINVAL;
>>>>  
>>>> +	if (cops->tcf_chain == NULL)
>>>> +		return -EOPNOTSUPP;
>>>> +
>>> You should probably repeat this in tc_dump_tfilter.
>>  
>>
>> ...In case somebody finds the way to list a filter before
>> adding it. ;-) But, since it's quite unlikely, let's foget it.
> 
> 
> ...or simply tries to do it instead of meditating the code.
> So this change is definitely needed in tc_dump_tfilter too.

Thanks Jarek. I'm on my way out the door, but I'll fix that tommorrow.
