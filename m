From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/5] Phonet: allocate a non-Ethernet ARP type
Date: Wed, 17 Dec 2008 16:07:50 +0200
Message-ID: <1229522874-20636-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:31020 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbYLQOIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 09:08:14 -0500
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBHE808o021598
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:08:09 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBHE7sdb016910
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:07:54 +0200
In-Reply-To: <200812171607.14184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also leave some room for more 802.11 types.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/if_arp.h |    2 ++
 net/core/dev.c         |    8 ++++----
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 4d34018..11df77a 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -87,6 +87,8 @@
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header=
 */
=20
+#define ARPHRD_PHONET	820		/* PhoNet media type		*/
+
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index d8d7d1f..15aab0c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -283,8 +283,8 @@ static const unsigned short netdev_lock_type[] =3D
 	 ARPHRD_PIMREG, ARPHRD_HIPPI, ARPHRD_ASH, ARPHRD_ECONET,
 	 ARPHRD_IRDA, ARPHRD_FCPP, ARPHRD_FCAL, ARPHRD_FCPL,
 	 ARPHRD_FCFABRIC, ARPHRD_IEEE802_TR, ARPHRD_IEEE80211,
-	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_VOID,
-	 ARPHRD_NONE};
+	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_PHONET,
+	 ARPHRD_VOID, ARPHRD_NONE};
=20
 static const char *netdev_lock_name[] =3D
 	{"_xmit_NETROM", "_xmit_ETHER", "_xmit_EETHER", "_xmit_AX25",
@@ -300,8 +300,8 @@ static const char *netdev_lock_name[] =3D
 	 "_xmit_PIMREG", "_xmit_HIPPI", "_xmit_ASH", "_xmit_ECONET",
 	 "_xmit_IRDA", "_xmit_FCPP", "_xmit_FCAL", "_xmit_FCPL",
 	 "_xmit_FCFABRIC", "_xmit_IEEE802_TR", "_xmit_IEEE80211",
-	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_VOID",
-	 "_xmit_NONE"};
+	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_PHONET",
+	 "_xmit_VOID", "_xmit_NONE"};
=20
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lo=
ck_type)];
 static struct lock_class_key netdev_addr_lock_key[ARRAY_SIZE(netdev_lo=
ck_type)];
--=20
1.5.4.3

