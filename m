From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 07/13] fsl/fman: MEMAC may use QSGMII PHY interface mode
Date: Tue, 4 Oct 2016 10:32:53 +0300
Message-ID: <1475566379-5078-8-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman_memac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_memac.c b/drivers/net/ethernet/freescale/fman/fman_memac.c
index 45e98fd..96dfe7e 100644
--- a/drivers/net/ethernet/freescale/fman/fman_memac.c
+++ b/drivers/net/ethernet/freescale/fman/fman_memac.c
@@ -1151,7 +1151,8 @@ struct fman_mac *memac_config(struct fman_mac_params *params)
 	/* Save FMan revision */
 	fman_get_revision(memac->fm, &memac->fm_rev_info);
 
-	if (memac->phy_if == PHY_INTERFACE_MODE_SGMII) {
+	if (memac->phy_if == PHY_INTERFACE_MODE_SGMII ||
+	    memac->phy_if == PHY_INTERFACE_MODE_QSGMII) {
 		if (!params->internal_phy_node) {
 			pr_err("PCS PHY node is not available\n");
 			memac_free(memac);
-- 
2.1.0
