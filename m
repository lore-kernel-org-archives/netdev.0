From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/4,RFC] support for DSA hardware ethernet switch chips
Date: Thu, 25 Sep 2008 18:34:34 +0200
Message-ID: <20080925163434.GA25190@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:59633 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbYIYQeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 12:34:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set adds support for hardware ethernet switches that use
the DSA (Distributed Switch Architecture) protocol.  These chips are
typically used in access points and DSL routers and such, where they
sit between the CPU's ethernet port and the external ethernet ports
on the box (typically 4 LAN ports and 1 WAN port).

This patch set supports the Marvell 88E6131/6123/6161/6165 switch
chips.  But since most of these chips work in very similar ways,
support for other brands and models of switches should not be hard
to add.

There are a couple of loose ends in the current code, e.g. unloading
the driver isn't handled at all, and it doesn't deal with the
underlying network device going away, and such.  These things aren't
too hard to handle -- I just wanted to get the patches out there and
get some feedback on the general design.


thanks,
Lennert
