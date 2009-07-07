From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/cs89x0.c: Avoid using magic number in
 set_dma_mode
Date: Mon, 06 Jul 2009 19:10:11 -0700 (PDT)
Message-ID: <20090706.191011.38865597.davem@davemloft.net>
References: <Pine.LNX.4.64.0907050922570.27464@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753700AbZGGCKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 22:10:04 -0400
In-Reply-To: <Pine.LNX.4.64.0907050922570.27464@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 5 Jul 2009 09:23:21 +0200 (CEST)

> The constant DMA_RX_MODE is defined to be 0x14 in the local include file
> cs89x0.h.  Since a constant with the same name is used elsewhere with
> set_dma_mode, it seems likely that this constant could be used here.
> 
> The semantic match that finds this problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied to net-next-2.6, thanks!
