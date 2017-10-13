From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v2 5/5] fsl/fman: add dpaa in module names
Date: Fri, 13 Oct 2017 17:50:12 +0300
Message-ID: <1507906212-10076-6-git-send-email-madalin.bucur@nxp.com>
References: <1507906212-10076-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <junote@outlook.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507906212-10076-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
