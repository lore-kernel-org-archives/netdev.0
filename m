From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 1/5] powerpc: document rgmii-rxid and rgmii-txid
 phy-connection-types
Date: Mon, 5 Nov 2007 12:15:35 -0600
Message-ID: <20071105121535.c423d095.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, paulus@samba.org
To: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33789 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbXKESRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 13:17:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A h/w bug requires we program the PHY in RGMII mode for internal delay
on the receive or transmit side only; document the new property values.

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 Documentation/powerpc/booting-without-of.txt |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index a96e853..b97721c 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1634,8 +1634,9 @@ platforms are moved over to use the flattened-device-tree model.
      MAC addresses passed by the firmware when no information other
      than indices is available to associate an address with a device.
    - phy-connection-type : a string naming the controller/PHY interface type,
-     i.e., "mii" (default), "rmii", "gmii", "rgmii", "rgmii-id", "tbi",
-     or "rtbi".
+     i.e., "mii" (default), "rmii", "gmii", "rgmii", "rgmii-id" (Internal
+     Delay), "rgmii-txid" (delay on TX only), "rgmii-rxid" (delay on RX only),
+     "tbi", or "rtbi".
 
    Example:
 	ucc@2000 {
-- 
1.5.2.2

