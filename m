From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci emac: use dma_{map, unmap}_single API for
 cache coherency
Date: Mon, 15 Mar 2010 15:47:57 -0700 (PDT)
Message-ID: <20100315.154757.08655237.davem@davemloft.net>
References: <1268133637-23399-1-git-send-email-nsekhar@ti.com>
	<87eijqbh8e.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nsekhar@ti.com, netdev@vger.kernel.org, srk@ti.com,
	davinci-linux-open-source@linux.davincidsp.com
To: khilman@deeprootsystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937008Ab0COWrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:47:36 -0400
In-Reply-To: <87eijqbh8e.fsf@deeprootsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hilman <khilman@deeprootsystems.com>
Date: Thu, 11 Mar 2010 14:56:01 -0800

> Sekhar Nori <nsekhar@ti.com> writes:
> 
>> The davinci emac driver uses some ARM specific DMA APIs
>> for cache coherency which have been removed from kernel
>> with the 2.6.34 merge.
>>
>> Modify the driver to use the dma_{map, unmap}_single() APIs
>> defined in dma-mapping.h
>>
>> Without this fix, the driver fails to compile on Linus's
>> tree.
>>
>> Tested on DM365 and OMAP-L138 EVMs.
>>
>> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
> 
> Acked-by: Kevin Hilman <khilman@deeprootsystems.com>
> 
> Verified that this is compiling/running again with v2.6.34-rc1.

Applied, thanks.
