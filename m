From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: smsc911x: Fix bug where PHY interrupts are
 overwritten by 0
Date: Thu, 16 Jun 2016 18:33:36 +0200
Message-ID: <20160616163336.GD28432@lunn.ch>
References: <1466092470-20958-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	sergei.shtylyov@cogentembedded.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50206 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbcFPQdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 12:33:39 -0400
Content-Disposition: inline
In-Reply-To: <1466092470-20958-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 10:54:30AM -0500, Jeremy Linton wrote:
> By default, mdiobus_alloc() sets the PHY's to polling mode, but a
> pointer size memcpy means that couple IRQs (depending
> on 32-bit or 64-bit kernels) end up being overwritten with
> a value of 0. This means that PHY_POLL is disabled and results
> in unpredictable behavior depending on the PHYs location on the mdio
> bus. Remove that memcpy and the now unused phy_irq member to force
> SMSC911x PHY's into polling mode 100% of the time.
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
