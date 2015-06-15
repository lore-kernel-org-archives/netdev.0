From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] seeq:Make functions have a return type of bool in the file
 ether3.c
Date: Mon, 15 Jun 2015 13:38:05 -0400
Message-ID: <1434389885-12691-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: linux@arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

This makes the functions ether3_probe_bus_8 and ether3_probe_bus_16
have a return type of bool now due to their return statement being
only able to evaluate  as either one or zero.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 drivers/net/ethernet/seeq/ether3.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index bdac936..412c28e 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -354,7 +354,7 @@ ether3_init_for_open(struct net_device *dev)
 	ether3_outw(priv(dev)->regs.command | CMD_RXON, REG_COMMAND);
 }
 
-static inline int
+static inline bool
 ether3_probe_bus_8(struct net_device *dev, int val)
 {
 	int write_low, write_high, read_low, read_high;
@@ -375,7 +375,7 @@ ether3_probe_bus_8(struct net_device *dev, int val)
 	return read_low == write_low && read_high == write_high;
 }
 
-static inline int
+static inline bool
 ether3_probe_bus_16(struct net_device *dev, int val)
 {
 	int read_val;
-- 
2.1.4
