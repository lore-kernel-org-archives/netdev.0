From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH 04/10] netdev: drop CONFIG_PPC_MERGE from Kconfig
Date: Fri,  1 Aug 2008 11:44:14 -0500
Message-ID: <1217609060-6381-5-git-send-email-galak@kernel.crashing.org>
References: <1217609060-6381-1-git-send-email-galak@kernel.crashing.org>
 <1217609060-6381-2-git-send-email-galak@kernel.crashing.org>
 <1217609060-6381-3-git-send-email-galak@kernel.crashing.org>
 <1217609060-6381-4-git-send-email-galak@kernel.crashing.org>
Cc: linux-kernel@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755712AbYHAQpk@vger.kernel.org>
In-Reply-To: <1217609060-6381-4-git-send-email-galak@kernel.crashing.org>
CC: netdev@vger.kernel.org
CC: jgarzik@pobox.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that arch/ppc is dead CONFIG_PPC_MERGE is always defined for all
powerpc platforms so we don't need to depend on it.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/Kconfig             |    2 +-
 drivers/net/ibm_newemac/Kconfig |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa533c2..4e89c81 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1812,7 +1812,7 @@ config FEC2
 
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
-	depends on PPC_MERGE && PPC_MPC52xx && PPC_BESTCOMM_FEC
+	depends on PPC_MPC52xx && PPC_BESTCOMM_FEC
 	select CRC32
 	select PHYLIB
 	---help---
diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ibm_newemac/Kconfig
index 70a3272..bcec732 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ibm_newemac/Kconfig
@@ -1,6 +1,6 @@
 config IBM_NEW_EMAC
 	tristate "IBM EMAC Ethernet support"
-	depends on PPC_DCR && PPC_MERGE
+	depends on PPC_DCR
 	select CRC32
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
-- 
1.5.5.1
