From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/6] [6LoWPAN] disable debugging by
	default
Date: Wed,  2 Nov 2011 19:34:19 +0300
Message-ID: <1320251659-2822-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111102162520.GA2669-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch disables debug output enabled by default.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 890ecef..e5709fa 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -50,8 +50,6 @@
  * SUCH DAMAGE.
  */
 
-#define DEBUG
-
 #include <linux/bitops.h>
 #include <linux/if_arp.h>
 #include <linux/module.h>
-- 
1.7.2.5


------------------------------------------------------------------------------
RSA&#174; Conference 2012
Save $700 by Nov 18
Register now&#33;
http://p.sf.net/sfu/rsa-sfdev2dev1
