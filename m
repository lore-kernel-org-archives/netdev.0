From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next v2] gianfar: Fix alloc_skb_resources on
 -ENOMEM cleanup path
Date: Fri, 09 Nov 2012 17:08:12 -0500 (EST)
Message-ID: <20121109.170812.1627720982777784196.davem@davemloft.net>
References: <1352448701-14041-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756117Ab2KIWIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 17:08:14 -0500
In-Reply-To: <1352448701-14041-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 9 Nov 2012 10:11:41 +0200

> Should gfar_init_bds() return with -ENOMEM inside gfar_alloc_skb_resources(),
> free_skb_resources() will be called twice in a row on the "cleanup" path,
> leading to duplicate kfree() calls for rx_|tx_queue->rx_|tx_skbuff resulting
> in segmentation fault.
> This patch prevents the segmentation fault to happen in the future
> (rx_|tx_sbkbuff set to NULL), and corrects the error path handling
> for gfar_init_bds().
> 
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
