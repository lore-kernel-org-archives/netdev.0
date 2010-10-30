From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/39] drivers/net/can: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:33 -0700
Message-ID: <2a00e2a377a44e544cec15356cf3794abe47b306.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing newlines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/can/mscan/mscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 64c378c..74cd880 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -182,7 +182,7 @@ static int mscan_restart(struct net_device *dev)
 
 		priv->can.state = CAN_STATE_ERROR_ACTIVE;
 		WARN(!(in_8(&regs->canmisc) & MSCAN_BOHOLD),
-		     "bus-off state expected");
+		     "bus-off state expected\n");
 		out_8(&regs->canmisc, MSCAN_BOHOLD);
 		/* Re-enable receive interrupts. */
 		out_8(&regs->canrier, MSCAN_RX_INTS_ENABLE);
-- 
1.7.3.1.g432b3.dirty
