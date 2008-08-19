From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] forcedeth: fix checksum flag
Date: Tue, 19 Aug 2008 22:58:42 +1000
Message-ID: <E1KVQnK-0001Re-00@gondolin.me.apana.org.au>
References: <20080818145442.659ab3a3.akpm@linux-foundation.org>
Cc: aabdulla@nvidia.com, jgarzik@pobox.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48771 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753342AbYHSM7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 08:59:19 -0400
In-Reply-To: <20080818145442.659ab3a3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> --- old/drivers/net/forcedeth.c       2008-08-14 18:37:11.000000000 -0400
>> +++ new/drivers/net/forcedeth.c       2008-08-14 18:37:05.000000000 -0400
>> @@ -5522,7 +5522,7 @@
>>       if (id->driver_data & DEV_HAS_CHECKSUM) {
>>               np->rx_csum = 1;
>>               np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
>> -             dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
>> +             dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
>>               dev->features |= NETIF_F_TSO;
>>       }
>>  
>> @@ -5835,7 +5835,7 @@
>>  
>>       dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
>>                  dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
>> -                dev->features & (NETIF_F_HW_CSUM | NETIF_F_SG) ?
>> +                dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
>>                       "csum " : "",
>>                  dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
>>                       "vlan " : "",
> 
> Is this fix needed in 2.6.25.x and 2.6.26.x?

Yep it's needed for all kernels.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
