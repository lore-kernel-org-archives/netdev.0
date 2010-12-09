From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 3/7] e1000e: cleanup: simplify E1000_ALL_*
	defines
Date: Thu,  9 Dec 2010 02:40:53 +0000
Message-ID: <1291862457-16671-4-git-send-email-asbjorn__43010.7292988852$1291863652$gmane$org@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Cleanup E1000_ALL_* so that each of them can fit on one line,
by reusing each other instead of solely using combinations of
ADVERTISE_* as defined right above it.

This fixes 2 checkpatch errors.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/defines.h |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 2b969c8..10760be 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -263,14 +263,11 @@
 #define ADVERTISE_1000_FULL               0x0020
 
 /* 1000/H is not supported, nor spec-compliant. */
-#define E1000_ALL_SPEED_DUPLEX ( ADVERTISE_10_HALF |   ADVERTISE_10_FULL | \
-				ADVERTISE_100_HALF |  ADVERTISE_100_FULL | \
-						     ADVERTISE_1000_FULL)
-#define E1000_ALL_NOT_GIG      ( ADVERTISE_10_HALF |   ADVERTISE_10_FULL | \
-				ADVERTISE_100_HALF |  ADVERTISE_100_FULL)
+#define E1000_ALL_10_SPEED     (ADVERTISE_10_HALF  |   ADVERTISE_10_FULL)
 #define E1000_ALL_100_SPEED    (ADVERTISE_100_HALF |  ADVERTISE_100_FULL)
-#define E1000_ALL_10_SPEED      (ADVERTISE_10_HALF |   ADVERTISE_10_FULL)
-#define E1000_ALL_HALF_DUPLEX   (ADVERTISE_10_HALF |  ADVERTISE_100_HALF)
+#define E1000_ALL_HALF_DUPLEX  (ADVERTISE_10_HALF  |  ADVERTISE_100_HALF)
+#define E1000_ALL_NOT_GIG      (E1000_ALL_10_SPEED | E1000_ALL_100_SPEED)
+#define E1000_ALL_SPEED_DUPLEX (E1000_ALL_NOT_GIG  | ADVERTISE_1000_FULL)
 
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT   E1000_ALL_SPEED_DUPLEX
 
-- 
1.7.2.3


------------------------------------------------------------------------------
This SF Dev2Dev email is sponsored by:

WikiLeaks The End of the Free Internet
http://p.sf.net/sfu/therealnews-com
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
