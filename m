From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 11/26] et131x: eliminate write only registry fields
Date: Tue, 25 Aug 2009 15:59:20 +0100
Message-ID: <20090825145918.16176.73765.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42605 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755329AbZHYPEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:04:42 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et131x_adapter.h |    4 ----
 drivers/staging/et131x/et131x_config.c  |    4 ----
 2 files changed, 0 insertions(+), 8 deletions(-)


diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index 8e811af..a7402a3 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -253,8 +253,6 @@ struct et131x_adapter {
 	/* Registry parameters */
 	u8 SpeedDuplex;		/* speed/duplex */
 	eFLOW_CONTROL_t RegistryFlowControl;	/* for 802.3x flow control */
-	u8 RegistryWOLMatch;	/* Enable WOL pattern-matching */
-	u8 RegistryWOLLink;	/* Link state change is independant */
 	u8 RegistryPhyComa;	/* Phy Coma mode enable/disable */
 
 	u32 RegistryRxMemEnd;	/* Size of internal rx memory */
@@ -269,9 +267,7 @@ struct et131x_adapter {
 	u32 RegistryRxTimeInterval;
 
 	/* Validation helpers */
-	u8 RegistryPMWOL;
 	u8 RegistryNMIDisable;
-	u32 RegistrySCGain;
 	u8 RegistryPhyLoopbk;	/* Enable Phy loopback */
 
 	/* Derived from the registry: */
diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/et131x/et131x_config.c
index 628d6ad..f8273d1 100644
--- a/drivers/staging/et131x/et131x_config.c
+++ b/drivers/staging/et131x/et131x_config.c
@@ -247,8 +247,6 @@ void et131x_config_parse(struct et131x_adapter *etdev)
 
 	etdev->RegistryVlanTag = PARM_VLAN_TAG_DEF;
 	etdev->RegistryFlowControl = PARM_FLOW_CTL_DEF;
-	etdev->RegistryWOLLink = PARM_WOL_LINK_DEF;
-	etdev->RegistryWOLMatch = PARM_WOL_MATCH_DEF;
 	etdev->RegistryJumboPacket = PARM_JUMBO_PKT_DEF;
 	etdev->RegistryPhyComa = PARM_PHY_COMA_DEF;
 	etdev->RegistryRxNumBuffers = PARM_RX_NUM_BUFS_DEF;
@@ -257,8 +255,6 @@ void et131x_config_parse(struct et131x_adapter *etdev)
 	etdev->RegistryTxTimeInterval = PARM_TX_TIME_INT_DEF;
 	etdev->RegistryRxMemEnd = PARM_RX_MEM_END_DEF;
 	etdev->RegistryMACStat = PARM_MAC_STAT_DEF;
-	etdev->RegistrySCGain = PARM_SC_GAIN_DEF;
-	etdev->RegistryPMWOL = PARM_PM_WOL_DEF;
 
 	if (et131x_nmi_disable != PARM_NMI_DISABLE_DEF)
 		etdev->RegistryNMIDisable = et131x_nmi_disable;

