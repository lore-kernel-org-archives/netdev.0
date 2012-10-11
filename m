From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Thu, 11 Oct 2012 18:38:51 +0200
Message-ID: <20121011183851.277e79da@skate>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<5076E9F1.60200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35907 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758852Ab2JKQjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 12:39:07 -0400
In-Reply-To: <5076E9F1.60200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob,

On Thu, 11 Oct 2012 10:46:57 -0500, Rob Herring wrote:

> > +Required properties:
> > +- compatible: should be "marvell,neta".
> 
> This should be more specific such as "marvell,armada-xp-neta".
> 
> Or use 370 instead of xp. It should be which ever chip came first.
> 
> > +- reg: address and length of the register set for the device.
> > +- interrupts: interrupt for the device
> > +- phy-mode: String, operation mode of the PHY interface. Supported
> > +  values are "sgmii" and "rmii".
> > +- phy-addr: Integer, address of the PHY.
> > +- device_type: should be "network".
> 
> Drop this. device_type is not used for FDT.
> 
> > +- clock-frequency: frequency of the peripheral clock of the SoC.
> > +
> > +Example:
> > +
> > +eth@d0070000 {
> 
> Should be ethernet@...

Thanks for your comments. Will fix in v3.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
