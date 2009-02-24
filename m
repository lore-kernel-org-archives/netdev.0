From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: replace linktype number by name for tunnels
Date: Tue, 24 Feb 2009 11:31:40 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902241129210.329@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.ogr
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:40408 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbZBXKnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 05:43:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sovereign.computergmbh.de (Postfix) with ESMTP id 9A12D441DBA5
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 11:43:29 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip link currently only shows [65534] for TUN-style tunnels, but 65534 
actually maps to a name.

$ ip l
6: tun1: <POINTOPOINT,MULTICAST,NOARP> mtu 1500 qdisc noop state DOWN qlen 500
    link/[65534] 

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

---
 lib/ll_types.c |    3 +++
 1 file changed, 3 insertions(+)

Index: iproute2-2.6.23/lib/ll_types.c
===================================================================
--- iproute2-2.6.23.orig/lib/ll_types.c
+++ iproute2-2.6.23/lib/ll_types.c
@@ -124,6 +124,9 @@ __PF(IEEE80211_PRISM,ieee802.11/prism)
 #ifdef ARPHRD_IEEE80211_RADIOTAP
 __PF(IEEE80211_RADIOTAP,ieee802.11/radiotap)
 #endif
+#ifdef ARPHRD_NONE
+__PF(NONE, none)
+#endif
 #ifdef ARPHRD_VOID
 __PF(VOID,void)
 #endif

