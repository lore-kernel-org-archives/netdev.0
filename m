From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: [PATCH] pch_can: fix tseg1/tseg2 setting issue
Date: Thu, 10 Feb 2011 09:39:59 +0900
Message-ID: <1297298399-6250-1-git-send-email-tomoya-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	toshiharu-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Previous patch "[PATCH 1/3] pch_can: fix 800k comms issue" is wrong.
I should have modified tseg1_min not tseg2_min.
This patch reverts tseg2_min to 1 and set tseg1_min to 2.

Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
---
 drivers/net/can/pch_can.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 7d8bc12..e54712b 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -185,9 +185,9 @@ struct pch_can_priv {
 
 static struct can_bittiming_const pch_can_bittiming_const = {
 	.name = KBUILD_MODNAME,
-	.tseg1_min = 1,
+	.tseg1_min = 2,
 	.tseg1_max = 16,
-	.tseg2_min = 2,
+	.tseg2_min = 1,
 	.tseg2_max = 8,
 	.sjw_max = 4,
 	.brp_min = 1,
-- 
1.7.3.4
