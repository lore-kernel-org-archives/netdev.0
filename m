From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 0/6] RESEND of missed ucc_geth phylib and SGMII patches
Date: Tue, 8 May 2007 17:50:04 -0500
Message-ID: <20070508175004.6b1ffee7.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33762 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968802AbXEHWuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 18:50:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is a re-send of the 6 patches that were missed:

submitted 10 apr 2007:

[PATCH] Add support for the Davicom DM9161A PHY
 - http://marc.info/?l=linux-netdev&m=117624199831581&w=2

submitted 13 apr 2007:

[PATCH v2] phylib: add the ICPlus IP175C PHY driver
 - http://marc.info/?l=linux-netdev&m=117648832616294&w=2

[PATCH v2] phylib: enable RGMII-ID on the Marvell m88e1111 PHY
 - http://marc.info/?l=linux-netdev&m=117648831716153&w=2

submitted 02 may 2007:

[PATCH] ucc_geth: eliminate max-speed, change interface
 - http://marc.info/?l=linux-netdev&m=117813384403311&w=2

submitted 03 may 2007:

[PATCH] gianfar: add support for SGMII
 - http://marc.info/?l=linux-netdev&m=117822321305231&w=2

[PATCH] phylib: m88e1111: enable SGMII mode
 - http://marc.info/?l=linux-netdev&m=117822321202167&w=2

Jeff, please apply; boards with ucc_geth are currently broken.

Thanks,

Kim

---
Kapil Juneja (2):
      gianfar: add support for SGMII
      phylib: m88e1111: enable SGMII mode

Kim Phillips (4):
      Add support for the Davicom DM9161A PHY
      phylib: add the ICPlus IP175C PHY driver
      phylib: enable RGMII-ID on the Marvell m88e1111 PHY
      ucc_geth: eliminate max-speed, change interface-type to phy-connection-type
 
 drivers/net/gianfar.c      |   27 +++++++++
 drivers/net/gianfar.h      |    6 ++
 drivers/net/gianfar_mii.c  |   55 +++++++++++++++----
 drivers/net/phy/Kconfig    |    6 ++
 drivers/net/phy/Makefile   |    1 +
 drivers/net/phy/davicom.c  |   34 +++++++++---
 drivers/net/phy/icplus.c   |  128 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/marvell.c  |   78 ++++++++++++++++++++++++---
 drivers/net/ucc_geth.c     |   40 ++++++--------
 drivers/net/ucc_geth_mii.c |    9 ++--
 drivers/net/ucc_geth_mii.h |   10 ++--
 11 files changed, 334 insertions(+), 60 deletions(-)
 create mode 100644 drivers/net/phy/icplus.c
