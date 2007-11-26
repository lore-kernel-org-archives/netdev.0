From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 1/3][RESEND] phylib: add PHY interface modes for internal
	delay for tx and rx only
Date: Mon, 26 Nov 2007 16:17:48 -0600
Message-ID: <20071126161748.9671b828.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Allow phylib specification of cases where hardware needs to configure
PHYs for Internal Delay only on either RX or TX (not both).

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
Tested-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Acked-by: Li Yang <leoli@freescale.com>
---
 include/linux/phy.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index f0742b6..e10763d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -58,6 +58,8 @@ typedef enum {
 	PHY_INTERFACE_MODE_RMII,
 	PHY_INTERFACE_MODE_RGMII,
 	PHY_INTERFACE_MODE_RGMII_ID,
+	PHY_INTERFACE_MODE_RGMII_RXID,
+	PHY_INTERFACE_MODE_RGMII_TXID,
 	PHY_INTERFACE_MODE_RTBI
 } phy_interface_t;
 
-- 
1.5.2.2
