From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] 8139cp: fix coherent mapping leak in error
 path.
Date: Sat, 01 Dec 2012 20:41:23 -0500 (EST)
Message-ID: <20121201.204123.2243524800902935850.davem@davemloft.net>
References: <20121201230850.GA10935@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, dwmw2@infradead.org, jasowang@redhat.com,
	netdev@vger.kernel.org, jogreene@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab2LBBlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 20:41:25 -0500
In-Reply-To: <20121201230850.GA10935@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, 2 Dec 2012 00:08:50 +0100

> cp_open
> [...]
>         rc = cp_alloc_rings(cp);
>         if (rc)
>                 return rc;
> 
> cp_alloc_rings
> [...]
>         mem = dma_alloc_coherent(&cp->pdev->dev, CP_RING_BYTES,
>                                  &cp->ring_dma, GFP_KERNEL);
> 
> - cp_alloc_rings never frees the coherent mapping it allocates
> - neither do cp_open when cp_alloc_rings fails
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
