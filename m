From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta and
 update help text
Date: Tue, 18 Feb 2014 14:58:09 +0100
Message-ID: <20140218135809.GD17984@lunn.ch>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20140218122952.GM7862@titan.lakedaemon.net>
 <20140218134532.7607a616@skate>
 <20140218125206.GN7862@titan.lakedaemon.net>
 <20140218141303.77c77272@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason@lakedaemon.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58525 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341AbaBRN6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 08:58:51 -0500
Content-Disposition: inline
In-Reply-To: <20140218141303.77c77272@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> At this point, I don't expect to see this IP in any other SOCs than
> Marvell Armada EBU, so I'll resend with a "depends on PLAT_ORION", as I
> agree it is much safer in terms of build problems.

Hi Thomas

PLAT_ORION is a bit of an odd thing now.

For me, PLAT_ORION means arch/arm/plat-orion. 

But as far as i know, 370/XP does not actually use anything from
arch/arm/plat-orion. When kirkwood moves into mach-mvebu, it also will
not use any code from it, and i suspect dove is the same.

So maybe in a few cycles, when only mach-orion5x is left, we can merge
arch/arm/plat-orion into arch/arm/mach-orion5x and PLAT_ORION goes
away?

Or do we want to define that PLAT_ORION means any system which can
make use of mvebu drivers?

     Andrew
