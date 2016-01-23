From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 23:31:17 +0000
Message-ID: <20160123233116.GD10826@n2100.arm.linux.org.uk>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
 <20160123190622.GA10826@n2100.arm.linux.org.uk>
 <20160123193705.GE3880@lunn.ch>
 <20160123194856.GB10826@n2100.arm.linux.org.uk>
 <20160123201647.GH3880@lunn.ch>
 <20160123204416.GC10826@n2100.arm.linux.org.uk>
 <20160123221232.GJ3880@lunn.ch>
 <20160123222326.GK3880@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:59294 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbcAWXbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 18:31:23 -0500
Content-Disposition: inline
In-Reply-To: <20160123222326.GK3880@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 11:23:26PM +0100, Andrew Lunn wrote:
> On Sat, Jan 23, 2016 at 11:12:32PM +0100, Andrew Lunn wrote:
> > Hi Russell
> > 
> > Never called.
> > 
> > So i guess we have a kernel configuration difference.
> > 
> > I don't have CONFIG_BRIDGE_VLAN_FILTERING.
> 
> Yep, confirmed. When i enable this option, and VLAN_8021Q which it
> depends on, i then have a working bridge.

It sounds like Vivien urgently needs to do some extra work to fix
the patches that created all this broken-ness, or we need to ask
davem to revert back to a known good working state.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
