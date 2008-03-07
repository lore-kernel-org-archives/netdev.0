From: Olof Johansson <olof@lixom.net>
Subject: Re: [Pasemi-linux] I2C MDIO support for pasemi_mac driver
Date: Fri, 7 Mar 2008 12:48:54 -0600
Message-ID: <20080307184854.GA23402@lixom.net>
References: <1204911643.8864.15.camel@localhost.localdomain> <20080307183738.GA22366@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org,
	afleming@freescale.com
To: Nathaniel Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56786 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758343AbYCGSnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 13:43:13 -0500
Content-Disposition: inline
In-Reply-To: <20080307183738.GA22366@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 12:37:38PM -0600, Olof Johansson wrote:

> The i2c bus number should be available in the phy driver when it's
> probed/registered, so you should be able to get to it there. It's awkward
> that the MDIO and i2c busses have separate namespaces, it'll make it hard
> if there's ever a system with both mdio and smbus-based phys. We could
> control that by how the mdio bus is specified in device tree on those
> systems though, and make sure the bus number for the "real" mdio bus is
> sufficiently offset to give room for the smbus-based bus numbers below.

On second thought, it might be a better idea to change from BUS:ID to
BUSTYPE:BUS:ID in phylib, to separate the namespaces.

That, plus a way to get to an i2c bus number from a device tree node,
and we should be all set. That might be tricker though.


-Olof
