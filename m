From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 0/18] net: dsa: HW bridging, EEE support
Date: Sat, 21 Mar 2015 08:46:37 -0700
Message-ID: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39943 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbCUPrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:47:06 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLc6-0000u6-GQ
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:47:04 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 to 7 of this series prepare the drivers using the mv88e6xxx code
for HW bridging support, without adding the code itself. For the most part
this factors out common port initialization code. There is no functional
change except for patch 3, which disables the message port bit for the
CPU port to prevent packet duplication if HW bridging is configured.

Patch 8 adds the infrastructure for hardware bridging support to the
mv88e6xxx code.

Patch 9 wires the MV88E6352 driver to support hardware bridging.

Patches 10 to 12 add support for ndo_fdb functions to the dsa subsystem, and
wire up the MV88E6352 driver to support those functions.

Patches 13 to 16 add EEE support and HW bridging support to the mv88e6171
driver. This set of patches is from Andrew, applied on top of the first
set of patches.

Patch 17 and 18 add HW bridging support to the mv88e6131 driver. This code
is untested and therefore marked RFT.

The series applies to net-next as of 3/20/2015.

Thanks a lot to Andrew Lunn for testing and valuable feedback.

---
Changes from RFT:
- Various bug fixes
  - Fixed packet duplication seen when HW bridging is enabled
- Cleanup; use more defines and restructure patches
- Added ndo_fdb functions
- New patches adding support for HW bridging and EEE support
  to the mv88e6171 driver.
