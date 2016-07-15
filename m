From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Fri, 15 Jul 2016 11:53:38 -0700 (PDT)
Message-ID: <20160715.115338.807171123778788554.davem@davemloft.net>
References: <1468506583-27299-1-git-send-email-p.zabel@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robh+dt@kernel.org, mark.rutland@arm.com,
	f.fainelli@gmail.com, devicetree@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, geert@linux-m68k.org
To: p.zabel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbcGOSxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:53:40 -0400
In-Reply-To: <1468506583-27299-1-git-send-email-p.zabel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philipp Zabel <p.zabel@pengutronix.de>
Date: Thu, 14 Jul 2016 16:29:43 +0200

> We can't detect the FXEN (fiber mode) bootstrap pin, so configure
> it via a boolean device tree property "micrel,fiber-mode".
> If it is enabled, auto-negotiation is not supported.
> The only available modes are 100base-fx (full duplex and half duplex).
> 
> Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>

Applied to net-next, thanks.
