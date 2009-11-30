From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] sfc: Turn pause frame generation on and off at
 the MAC, not the RX FIFO
Date: Sun, 29 Nov 2009 16:47:50 -0800 (PST)
Message-ID: <20091129.164750.226469571.davem@davemloft.net>
References: <1259502138.3709.42.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57085
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752265AbZK3Aro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 19:47:44 -0500
In-Reply-To: <1259502138.3709.42.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 29 Nov 2009 13:42:18 +0000

> Pause frame generation is gated by both RX_XOFF_MAC_EN and an enable
> bit in each MAC.  RX_XOFF_MAC_EN bit always reads back as 0 so we need
> to set it correctly every time we modify RX_CFG_REG.  Simplify this by
> always setting it to 1 and only changing the enable bits in the MACs.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
