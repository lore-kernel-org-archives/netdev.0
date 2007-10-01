From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 05/10] Add divisor.
Date: Mon, 01 Oct 2007 13:47:04 -0700
Message-ID: <47015CC8.2080507@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199772834-git-send-email-bugfood-ml@fatooh.org> <4700F83F.9020300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41613 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbXJAUrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:47:11 -0400
In-Reply-To: <4700F83F.9020300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Make hash divisor user-configurable.
>>
> 
>> @@ -120,7 +121,7 @@ static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1
>>  	/* Have we any rotation primitives? If not, WHY? */
>>  	h ^= (h1<<pert) ^ (h1>>(0x1F - pert));
>>  	h ^= h>>10;
>> -	return h & 0x3FF;
>> +	return h & (q->hash_divisor-1);
> 
> 
> This assumes that hash_divisor is a power of two, but this is
> not enforced anywhere.

Ok. I'll move that part from userspace to the kernel. That should be 
better anyway.

-Corey
