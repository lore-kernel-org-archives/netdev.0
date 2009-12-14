From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: CAN_MCP251X should depend on HAS_DMA
Date: Sun, 13 Dec 2009 19:58:15 -0800 (PST)
Message-ID: <20091213.195815.245417086.davem@davemloft.net>
References: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chripell@fsfe.org, wg@grandegger.com, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756622AbZLND6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:58:13 -0500
In-Reply-To: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sun, 13 Dec 2009 20:11:06 +0100 (CET)

> When building for Sun 3:
> 
> drivers/net/can/mcp251x.c:1074: undefined reference to `dma_free_coherent'
> drivers/net/can/mcp251x.c:976: undefined reference to `dma_alloc_coherent'
> drivers/net/can/mcp251x.c:1050: undefined reference to `dma_free_coherent'
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied.
