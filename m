From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: CAN_MCP251X should depend on HAS_DMA
Date: Sun, 13 Dec 2009 17:40:20 -0800 (PST)
Message-ID: <20091213.174020.26980813.davem@davemloft.net>
References: <alpine.DEB.2.00.0912132008100.21225@ayla.of.borg>
	<4B2552C8.4090105@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, chripell@fsfe.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959AbZLNBkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 20:40:19 -0500
In-Reply-To: <4B2552C8.4090105@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sun, 13 Dec 2009 21:47:04 +0100

> DMA can be selected with the module parameter "mcp251x_enable_dma" and
> is *off* by default. Therefore the driver does in principle not depend
> on HAS_DMA but I'm not sure if it's worth to handle it with #idef's.
> Christian? Any thought?

I still think it's a reasonable dependency.

You're not going to find this device on a s390 system. :-)
