From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 08/13] fsl/fman: check pcsphy pointer before use
Date: Tue, 4 Oct 2016 10:32:54 +0300
Message-ID: <1475566379-5078-9-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linuxppc-dev@lists.ozlabs.org>,
        <linux-kernel@vger.kernel.org>, <linuxdev.baldrick@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman_memac.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/fman_memac.c b/drivers/net/ethernet/freescale/fman/fman_memac.c
index 96dfe7e..53ef51e 100644
--- a/drivers/net/ethernet/freescale/fman/fman_memac.c
+++ b/drivers/net/ethernet/freescale/fman/fman_memac.c
@@ -507,6 +507,9 @@ static void setup_sgmii_internal_phy(struct fman_mac *memac,
 {
 	u16 tmp_reg16;
 
+	if (WARN_ON(!memac->pcsphy))
+		return;
+
 	/* SGMII mode */
 	tmp_reg16 = IF_MODE_SGMII_EN;
 	if (!fixed_link)
-- 
2.1.0
