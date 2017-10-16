From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v3 5/6] fsl/fman: add dpaa in module names
Date: Mon, 16 Oct 2017 21:36:09 +0300
Message-ID: <1508178970-28945-6-git-send-email-madalin.bucur@nxp.com>
References: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <junote@outlook.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change just renames the FMan driver modules, using a common prefix
for the DPAA FMan and DPAA Ethernet drivers. Besides making the names more
aligned, this allows writing udev rules that match on either driver name,
if needed, using the fsl_dpaa_* prefix. The change of netdev dev required
for the DSA probing makes the previous rules written using this prefix
fail, this change makes them work again, ensuring backwards compatibility
for their users.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/Makefile | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index 2c38119..4ae524a 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -1,9 +1,9 @@
 subdir-ccflags-y +=  -I$(srctree)/drivers/net/ethernet/freescale/fman
 
-obj-$(CONFIG_FSL_FMAN) += fsl_fman.o
-obj-$(CONFIG_FSL_FMAN) += fsl_fman_port.o
-obj-$(CONFIG_FSL_FMAN) += fsl_mac.o
+obj-$(CONFIG_FSL_FMAN) += fsl_dpaa_fman.o
+obj-$(CONFIG_FSL_FMAN) += fsl_dpaa_fman_port.o
+obj-$(CONFIG_FSL_FMAN) += fsl_dpaa_mac.o
 
-fsl_fman-objs	:= fman_muram.o fman.o fman_sp.o fman_keygen.o
-fsl_fman_port-objs := fman_port.o
-fsl_mac-objs:= mac.o fman_dtsec.o fman_memac.o fman_tgec.o
+fsl_dpaa_fman-objs	:= fman_muram.o fman.o fman_sp.o fman_keygen.o
+fsl_dpaa_fman_port-objs := fman_port.o
+fsl_dpaa_mac-objs:= mac.o fman_dtsec.o fman_memac.o fman_tgec.o
-- 
2.1.0
