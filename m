From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/15] ehea: Remove force_irq logic in napi poll routine
Date: Wed, 11 May 2011 23:06:23 -0400 (EDT)
Message-ID: <20110511.230623.1659397873403755531.davem@davemloft.net>
References: <20110512005213.897432612@samba.org>
	<20110512005622.766206152@samba.org>
	<1305167470.6124.10.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757028Ab1ELDJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 23:09:23 -0400
In-Reply-To: <1305167470.6124.10.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 11 May 2011 19:31:10 -0700

> On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
>> commit 18604c548545 (ehea: NAPI multi queue TX/RX path for SMP) added
>> driver specific logic for exiting napi mode. I'm not sure what it was
>> trying to solve and it should be up to the network stack to decide when
>> we are done polling so remove it.
>> Signed-off-by: Anton Blanchard <anton@samba.org>
> 
>> +++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:51.960153456 +1000
>> @@ -937,18 +936,13 @@ static int ehea_poll(struct napi_struct
> []
>> +	while ((rx != budget)) {
> 
> one level of parentheses is enough.

Agreed.
