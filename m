From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
Subject: [PATCH 3/3] ieee802154/at86rf230: Fix register
	names for RX_AACK_ON and TX_ARET_ON
Date: Tue, 26 Mar 2013 22:41:31 +0000
Message-ID: <1364337691-20163-4-git-send-email-stefan@datenfreihafen.org>
References: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364337691-20163-1-git-send-email-stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The register names have been wrong since the beginning but it only showed up now
as they are actualy used for the upcoming auto ACK support.

Signed-off-by: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 2ff1f20..6e88eab 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -233,8 +233,8 @@ struct at86rf230_local {
 #define STATE_SLEEP		0x0F
 #define STATE_BUSY_RX_AACK	0x11
 #define STATE_BUSY_TX_ARET	0x12
-#define STATE_BUSY_RX_AACK_ON	0x16
-#define STATE_BUSY_TX_ARET_ON	0x19
+#define STATE_RX_AACK_ON	0x16
+#define STATE_TX_ARET_ON	0x19
 #define STATE_RX_ON_NOCLK	0x1C
 #define STATE_RX_AACK_ON_NOCLK	0x1D
 #define STATE_BUSY_RX_AACK_NOCLK 0x1E
-- 
1.7.10.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
