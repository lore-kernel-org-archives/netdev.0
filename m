From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about drivers/net/ethernet/mellanox/mlx4/en_tx.c
Date: Tue, 27 Aug 2013 19:07:10 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1308271904520.2282@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: amirv@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:33814 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751711Ab3H0RHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 13:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was wondering why in drivers/net/ethernet/mellanox/mlx4/en_tx.c there
are a number of uses of dma_sync_single_for_cpu without corresponding uses
of dma_sync_single_for_device (for example in mlx4_en_rx_skb)?  In most
drivers they come together.

thanks,
julia
