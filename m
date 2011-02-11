From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 3/4] batman-adv: Remove duplicate types.h
	inclusions
Date: Sat, 12 Feb 2011 00:21:42 +0100
Message-ID: <1297466503-13246-4-git-send-email-sven@narfation.org>
References: <1297466503-13246-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing-8gDhuhu/iIQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1297466503-13246-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus L=C3=BCssing <linus.luessing-8gDhuhu/iIQ@public.gmane.org>

types.h is included by main.h, which is included at the beginning of any
other c-file anyway. Therefore this commit removes those duplicate
inclussions.

Signed-off-by: Linus L=C3=BCssing <linus.luessing-8gDhuhu/iIQ@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/icmp_socket.c       |    1 -
 net/batman-adv/icmp_socket.h       |    2 --
 net/batman-adv/main.c              |    1 -
 net/batman-adv/routing.c           |    1 -
 net/batman-adv/routing.h           |    2 --
 net/batman-adv/send.c              |    1 -
 net/batman-adv/send.h              |    2 --
 net/batman-adv/soft-interface.c    |    1 -
 net/batman-adv/translation-table.c |    1 -
 net/batman-adv/translation-table.h |    2 --
 10 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 5e86d6f..319a7cc 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -24,7 +24,6 @@
 #include <linux/slab.h>
 #include "icmp_socket.h"
 #include "send.h"
-#include "types.h"
 #include "hash.h"
 #include "originator.h"
 #include "hard-interface.h"
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 08b1859..462b190 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -22,8 +22,6 @@
 #ifndef _NET_BATMAN_ADV_ICMP_SOCKET_H_
 #define _NET_BATMAN_ADV_ICMP_SOCKET_H_
=20
-#include "types.h"
-
 #define ICMP_SOCKET "socket"
=20
 void bat_socket_init(void);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index dc9248d..06d956c 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -30,7 +30,6 @@
 #include "translation-table.h"
 #include "hard-interface.h"
 #include "gateway_client.h"
-#include "types.h"
 #include "vis.h"
 #include "hash.h"
=20
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 028f739..8274140 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -28,7 +28,6 @@
 #include "icmp_socket.h"
 #include "translation-table.h"
 #include "originator.h"
-#include "types.h"
 #include "ring_buffer.h"
 #include "vis.h"
 #include "aggregation.h"
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index ceeca6f..a09d16f 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -22,8 +22,6 @@
 #ifndef _NET_BATMAN_ADV_ROUTING_H_
 #define _NET_BATMAN_ADV_ROUTING_H_
=20
-#include "types.h"
-
 void slide_own_bcast_window(struct batman_if *batman_if);
 void receive_bat_packet(struct ethhdr *ethhdr,
 				struct batman_packet *batman_packet,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 7cc620e..8314276 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -25,7 +25,6 @@
 #include "translation-table.h"
 #include "soft-interface.h"
 #include "hard-interface.h"
-#include "types.h"
 #include "vis.h"
 #include "aggregation.h"
 #include "gateway_common.h"
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index bc53ade..b68c272 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -22,8 +22,6 @@
 #ifndef _NET_BATMAN_ADV_SEND_H_
 #define _NET_BATMAN_ADV_SEND_H_
=20
-#include "types.h"
-
 int send_skb_packet(struct sk_buff *skb,
 				struct batman_if *batman_if,
 				uint8_t *dst_addr);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
index 145e0f7..bd088f8 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -26,7 +26,6 @@
 #include "send.h"
 #include "bat_debugfs.h"
 #include "translation-table.h"
-#include "types.h"
 #include "hash.h"
 #include "gateway_common.h"
 #include "gateway_client.h"
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translat=
ion-table.c
index f6917dd..7fb6726 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -22,7 +22,6 @@
 #include "main.h"
 #include "translation-table.h"
 #include "soft-interface.h"
-#include "types.h"
 #include "hash.h"
 #include "originator.h"
=20
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translat=
ion-table.h
index a4f3a37..f19931c 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -22,8 +22,6 @@
 #ifndef _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
 #define _NET_BATMAN_ADV_TRANSLATION_TABLE_H_
=20
-#include "types.h"
-
 int hna_local_init(struct bat_priv *bat_priv);
 void hna_local_add(struct net_device *soft_iface, uint8_t *addr);
 void hna_local_remove(struct bat_priv *bat_priv,
--=20
1.7.2.3
