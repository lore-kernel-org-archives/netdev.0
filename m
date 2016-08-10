From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH v6 1/3] net: Add mask for Control register 10Mbps speed
Date: Wed, 10 Aug 2016 11:20:06 +0530
Message-ID: <1470808208-32133-2-git-send-email-appanad@xilinx.com>
References: <1470808208-32133-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>, <michal.simek@xilinx.com>,
 <soren.brinkmann@xilinx.com>, <appanad@xilinx.com>, <f.fainelli@gmail.com>,
 <andrew@lunn.ch>, <punnaia@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470808208-32133-1-git-send-email-appanad@xilinx.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds mask for the Control register
10Mbps speed.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v6:
- None.
Changes for v5:
- New patch.

 include/uapi/linux/mii.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/mii.h b/include/uapi/linux/mii.h
index 237fac4..15d8510 100644
--- a/include/uapi/linux/mii.h
+++ b/include/uapi/linux/mii.h
@@ -48,6 +48,7 @@
 #define BMCR_SPEED100		0x2000	/* Select 100Mbps              */
 #define BMCR_LOOPBACK		0x4000	/* TXD loopback bits           */
 #define BMCR_RESET		0x8000	/* Reset to default state      */
+#define BMCR_SPEED10		0x0000	/* Select 10Mbps               */
 
 /* Basic mode status register. */
 #define BMSR_ERCAP		0x0001	/* Ext-reg capability          */
-- 
2.1.2
