From: Olaf Hering <olh@suse.de>
Subject: [PATCH 78/82] remove linux/version.h from net/ieee80211/
Date: Sun, 10 Jul 2005 19:36:26 +0000
Message-ID: <36408.8228474886$1121024462@news.gmane.org>
References: <20050710193508.0.PmFpst2252.2247.olh@nectarine.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050710193508.0.PmFpst2252.2247.olh@nectarine.suse.de>  
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


changing CONFIG_LOCALVERSION rebuilds too much, for no appearent reason.

Signed-off-by: Olaf Hering <olh@suse.de>

net/ieee80211/ieee80211_crypt.c      |    1 -
net/ieee80211/ieee80211_crypt_ccmp.c |    1 -
net/ieee80211/ieee80211_crypt_tkip.c |    1 -
net/ieee80211/ieee80211_crypt_wep.c  |    1 -
net/ieee80211/ieee80211_module.c     |    1 -
net/ieee80211/ieee80211_rx.c         |    1 -
net/ieee80211/ieee80211_tx.c         |    1 -
net/ieee80211/ieee80211_wx.c         |    1 -
8 files changed, 8 deletions(-)

Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_crypt.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt.c
@@ -12,7 +12,6 @@
*/

#include <linux/config.h>
-#include <linux/version.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt_ccmp.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_crypt_ccmp.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt_ccmp.c
@@ -10,7 +10,6 @@
*/

#include <linux/config.h>
-#include <linux/version.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt_tkip.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_crypt_tkip.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt_tkip.c
@@ -10,7 +10,6 @@
*/

#include <linux/config.h>
-#include <linux/version.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt_wep.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_crypt_wep.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_crypt_wep.c
@@ -10,7 +10,6 @@
*/

#include <linux/config.h>
-#include <linux/version.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_module.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_module.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_module.c
@@ -46,7 +46,6 @@
#include <linux/slab.h>
#include <linux/tcp.h>
#include <linux/types.h>
-#include <linux/version.h>
#include <linux/wireless.h>
#include <linux/etherdevice.h>
#include <asm/uaccess.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_rx.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_rx.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_rx.c
@@ -29,7 +29,6 @@
#include <linux/slab.h>
#include <linux/tcp.h>
#include <linux/types.h>
-#include <linux/version.h>
#include <linux/wireless.h>
#include <linux/etherdevice.h>
#include <asm/uaccess.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_tx.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_tx.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_tx.c
@@ -39,7 +39,6 @@
#include <linux/slab.h>
#include <linux/tcp.h>
#include <linux/types.h>
-#include <linux/version.h>
#include <linux/wireless.h>
#include <linux/etherdevice.h>
#include <asm/uaccess.h>
Index: linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_wx.c
===================================================================
--- linux-2.6.13-rc2-mm1.orig/net/ieee80211/ieee80211_wx.c
+++ linux-2.6.13-rc2-mm1/net/ieee80211/ieee80211_wx.c
@@ -30,7 +30,6 @@

******************************************************************************/
#include <linux/wireless.h>
-#include <linux/version.h>
#include <linux/kmod.h>
#include <linux/module.h>
