From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] gianfar: Fix dma check map error when
 DMA_API_DEBUG is enabled
Date: Thu, 11 Dec 2014 14:27:51 -0500 (EST)
Message-ID: <20141211.142751.14939995747583356.davem@davemloft.net>
References: <20141211020646.GB18701@pek-khao-d1.corp.ad.wrs.com>
	<1418278121-20209-1-git-send-email-haokexin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: haokexin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758691AbaLKT1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:27:54 -0500
In-Reply-To: <1418278121-20209-1-git-send-email-haokexin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hao <haokexin@gmail.com>
Date: Thu, 11 Dec 2014 14:08:41 +0800

> We need to use dma_mapping_error() to check the dma address returned
> by dma_map_single/page(). Otherwise we would get warning like this:
 ...
> For TX, we need to unmap the pages which has already been mapped and
> free the skb before return.
> 
> For RX, move the dma mapping and error check to gfar_new_skb(). We
> would reuse the original skb in the rx ring when either allocating
> skb failure or dma mapping error.
> 
> Signed-off-by: Kevin Hao <haokexin@gmail.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
> v2: Just update the RX path to reuse the original skb when dma mapping error
>     occurs as suggested by David.

Looks good, applied, thanks.
