From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net 2/3] batman: fix duplicate #include of multicast.h
Date: Thu,  7 Aug 2014 06:50:46 -0600
Message-ID: <1407415846-10277-4-git-send-email-sakiwit@gmail.com>
Cc: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	b.a.t.m.a.n@lists.open-mesh.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:48147 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252AbaHGMvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 08:51:06 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so5182366pdb.13
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 05:51:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The header multicast.h was included twice, so delete one of them.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Marek Lindner <mareklindner@neomailbox.ch>
Cc: Simon Wunderlich <sw@simonwunderlich.de>
Cc: Antonio Quartulli <antonio@meshcoding.com>
Cc: b.a.t.m.a.n@lists.open-mesh.org
---
 net/batman-adv/multicast.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/multicast.c b/net/batman-adv/multicast.c
index 96b66fd30f96..ab6bb2af1d45 100644
--- a/net/batman-adv/multicast.c
+++ b/net/batman-adv/multicast.c
@@ -19,9 +19,8 @@
 #include "multicast.h"
 #include "originator.h"
 #include "hard-interface.h"
 #include "translation-table.h"
-#include "multicast.h"
 
 /**
  * batadv_mcast_mla_softif_get - get softif multicast listeners
  * @dev: the device to collect multicast addresses from
