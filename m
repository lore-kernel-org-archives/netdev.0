From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sfq: add dummy bind/unbind handles
Date: Sun, 08 Aug 2010 09:04:46 +0200
Message-ID: <4C5E570E.6020908@gmail.com>
References: <20100806145818.66d389eb@nehalam>	<20100806152313.43abc30b@nehalam>	<4C5C97F3.3010604@gmail.com> <20100807.224514.137860816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, franchoze@yandex.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60569 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095Ab0HHHEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 03:04:53 -0400
Received: by bwz3 with SMTP id 3so663078bwz.19
        for <netdev@vger.kernel.org>; Sun, 08 Aug 2010 00:04:52 -0700 (PDT)
In-Reply-To: <20100807.224514.137860816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 08.08.2010 07:45:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 07 Aug 2010 01:17:07 +0200
> 
>> Stephen Hemminger wrote, On 07.08.2010 00:23:
>>
>>> Applying a filter to an SFQ qdisc would cause null dereference
>>> in tcf_bind_filter because although SFQ is classful it didn't
>>> have all the necessary equipment.
>>>
>>> Better alternative to changing tcf_bind API is to just fix
>>> SFQ.  This should go to net-2.6 and stable.
>>>
>>
>> Hmm... FYI, actually I've sent already a similar patch to the
>> original bug report thread (except .unbind_tcf method which
>> doesn't matter for fixing this bug, so should be rather
>> implemented in a separate patch, if needed at all in this
>> case).
> 
> Agreed, I can't see a way that unbind can ever be invoked
> if the bind call always returns zero.

To tell the truth, I think unbind should be implemented anyway,
just for consistency, safety, and easier verification. But, looking
at a similar case of .get and .put in the same driver, Patrick
seemed to do it purposely, so I expected some discussion about the
rules yet, and made it minimal to ease merging to older kernels.
 
Thanks,
Jarek P.
