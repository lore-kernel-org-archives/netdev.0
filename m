From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 08/12] net: mvpp2: remove unused register
 definitions
Date: Thu,  2 Feb 2017 16:51:37 +0100
Message-ID: <1486050701-27899-9-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1486050701-27899-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1486050701-27899-1-git-send-email-thomas.petazzoni@free-electrons.com>
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

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index e7d0da6..ef68780 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -253,10 +253,6 @@
 #define MVPP2_SRC_ADDR_HIGH			0x28
 #define MVPP2_PHY_AN_CFG0_REG			0x34
 #define     MVPP2_PHY_AN_STOP_SMI0_MASK		BIT(7)
-#define MVPP2_MIB_COUNTERS_BASE(port)		(0x1000 + ((port) >> 1) * \
-						0x400 + (port) * 0x400)
-#define     MVPP2_MIB_LATE_COLLISION		0x7c
-#define MVPP2_ISR_SUM_MASK_REG			0x220c
 #define MVPP2_MNG_EXTENDED_GLOBAL_CTRL_REG	0x305c
 #define MVPP2_EXT_GLOBAL_CTRL_DEFAULT		0x27
 
-- 
2.7.4
