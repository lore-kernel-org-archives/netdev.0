From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2] Network driver for the Armada 370 and Armada XP ARM Marvell SoCs
Date: Thu, 11 Oct 2012 17:27:58 +0200
Message-ID: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35206 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab2JKP2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:28:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Lennert,

This patch set adds a new network driver for the network unit
available in the newest Marvell ARM SoCs Armada 370 and Armada XP, as
well as the necessary Device Tree information to use this driver in
the two evaluation platforms of those SoCs.

In details:

 * Patch 1 contains the driver itself. The commit log contains a
   detailed explanation about why a new driver is needed for this new
   Marvell SoC, compared to older Marvell SoCs (Orion, Kirkwood, Dove)
   that use the mv643xx_eth driver.

 * Patch 2 adds the necessary entry to the MAINTAINERS file.

 * Patch 3 adds the SoC-level Device Tree information for Armada 370
   and Armada XP.

 * Patch 4 adds the board-level Device Tree information for the
   Marvell evaluation boards of Armada 370 and Armada XP.

Changes since v1:
 * Reduced the Cc: list in order to make the patch set acceptable for
   the netdev@ mailing list.
 * Merge the mvneta.h contents into mvneta.c, since the header was
   only used by the driver. Requested by Arnd Bergmann.
 * Completely reorganize the organization of the register list and
   register values, in order to make it more consistent, and hopefully
   easier to read (especially easier to match register values with the
   corresponding register).
 * Integrate with the phylib, as suggested by Florian Fainelli, and
   remove the link management code that has become useless as the
   result of this integration
 * Fix many small details suggested by Florian Fainelli in his review
   of the first driver
 * Simplify various parts of the driver (descriptors array allocation,
   data structures, etc.)

Note that version 1 never made it to the netdev@ mailing list, due to
a too long list of Cc's, so this version 2 is the first version that
netdev@ readers will actually see.

Thanks,

Thomas Petazzoni
