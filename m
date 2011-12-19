From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 09/14] ieee802154: remove ieee802154
	policy from globals
Date: Mon, 19 Dec 2011 19:33:49 +0300
Message-ID: <1324312434-13151-9-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111219163117.GA13123@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111219163117.GA13123-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Move ieee802154 netlink policy array definition inside ieee802154 layer.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/nl802154.h    |    2 --
 net/ieee802154/ieee802154.h |    2 ++
 net/ieee802154/wpan-class.c |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/nl802154.h b/include/linux/nl802154.h
index 33d9f51..d2b5ae2 100644
--- a/include/linux/nl802154.h
+++ b/include/linux/nl802154.h
@@ -74,8 +74,6 @@ enum {
 
 #define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
 
-extern const struct nla_policy ieee802154_policy[];
-
 /* commands */
 /* REQ should be responded with CONF
  * and INDIC with RESP
diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index aadec42..e9799af 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -21,6 +21,8 @@
 int __init ieee802154_nl_init(void);
 void __exit ieee802154_nl_exit(void);
 
+extern const struct nla_policy ieee802154_policy[];
+
 #define IEEE802154_OP(_cmd, _func)			\
 	{						\
 		.cmd	= _cmd,				\
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 1627ef2..36d32e2 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/device.h>
 
+#include <net/netlink.h>
 #include <net/wpan-phy.h>
 
 #include "ieee802154.h"
-- 
1.7.2.3


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
