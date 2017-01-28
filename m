From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 2/2] batman-adv: Fix includes for
	IS_ERR/ERR_PTR
Date: Sat, 28 Jan 2017 11:56:51 +0100
Message-ID: <20170128105651.3061-3-sw@simonwunderlich.de>
References: <20170128105651.3061-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170128105651.3061-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

IS_ERR/ERR_PTR are not defined in linux/device.h but in linux/err.h. The
files using these macros therefore have to include the correct one.

Reported-by: Linus Luessing <linus.luessing-S0/GAf8tV78@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/debugfs.c  | 2 +-
 net/batman-adv/tp_meter.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 5406148b9497..e32ad47c6efd 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -19,7 +19,7 @@
 #include "main.h"
 
 #include <linux/debugfs.h>
-#include <linux/device.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/export.h>
 #include <linux/fs.h>
diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index 07f64b60b528..c94ebdecdc3d 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -23,7 +23,7 @@
 #include <linux/byteorder/generic.h>
 #include <linux/cache.h>
 #include <linux/compiler.h>
-#include <linux/device.h>
+#include <linux/err.h>
 #include <linux/etherdevice.h>
 #include <linux/fs.h>
 #include <linux/if_ether.h>
-- 
2.11.0
