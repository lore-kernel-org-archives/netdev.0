From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 6/7] drivers/net/ethernet: remove unused #define.
Date: Fri, 30 Sep 2011 12:38:49 +0200
Message-ID: <20110930103849.GG26727@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54249 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab1I3KkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:40:22 -0400
Content-Disposition: inline
In-Reply-To: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/amd/depca.h       |    2 --
 drivers/net/ethernet/dec/tulip/de4x5.h |    2 --
 drivers/net/ethernet/jme.h             |    1 -
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/depca.h b/drivers/net/ethernet/amd/depca.h
index ee42648..cdcfe42 100644
--- a/drivers/net/ethernet/amd/depca.h
+++ b/drivers/net/ethernet/amd/depca.h
@@ -157,8 +157,6 @@
 */
 #include <linux/sockios.h>
 
-#define	DEPCAIOCTL	SIOCDEVPRIVATE
-
 struct depca_ioctl {
 	unsigned short cmd;                /* Command to run */
 	unsigned short len;                /* Length of the data buffer */
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.h b/drivers/net/ethernet/dec/tulip/de4x5.h
index 9f28774..ec756eb 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.h
+++ b/drivers/net/ethernet/dec/tulip/de4x5.h
@@ -991,8 +991,6 @@
 */
 #include <linux/sockios.h>
 
-#define	DE4X5IOCTL	SIOCDEVPRIVATE
-
 struct de4x5_ioctl {
 	unsigned short cmd;                /* Command to run */
 	unsigned short len;                /* Length of the data buffer */
diff --git a/drivers/net/ethernet/jme.h b/drivers/net/ethernet/jme.h
index c1f8b89..02ea27c 100644
--- a/drivers/net/ethernet/jme.h
+++ b/drivers/net/ethernet/jme.h
@@ -102,7 +102,6 @@ enum jme_spi_op_bits {
 };
 
 #define HALF_US 500	/* 500 ns */
-#define JMESPIIOCTL	SIOCDEVPRIVATE
 
 #define PCI_PRIV_PE1		0xE4
 
-- 
1.7.6.2
