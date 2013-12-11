From: phdm@macqel.be
Subject: [PATCH] net:fec: remove duplicate lines in comment about errata ERR006358
Date: Wed, 11 Dec 2013 23:50:52 +0100
Message-ID: <1386802252-5817-1-git-send-email-phdm@macqel.be>
Cc: Philippe De Muyter <phdm@macqel.be>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	frank.li@freescale.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe De Muyter <phdm@macqel.be>

commit 031916568a1aa2ef1809f86d26f0bcfa215ff5c0 worked around
errata ERR006358, but comment contains duplicated lines, impairing
the readability.  Remove them.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4cbebf3..36bcc48 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -98,10 +98,6 @@ static void set_multicast_list(struct net_device *ndev);
  * detected as not set during a prior frame transmission, then the
  * ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs
  * were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in
- * If the ready bit in the transmit buffer descriptor (TxBD[R]) is previously
- * detected as not set during a prior frame transmission, then the
- * ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs
- * were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in
  * frames not being transmitted until there is a 0-to-1 transition on
  * ENET_TDAR[TDAR].
  */
-- 
1.7.5.3
