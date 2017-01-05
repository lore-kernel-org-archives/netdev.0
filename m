From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net-next 1/2] net/sched: Kconfig: select LIBCRC32C if NET_ACT_CSUM is selected
Date: Thu,  5 Jan 2017 17:59:02 +0100
Message-ID: <2d9a13868f985c55d2a4f322bbcc3f38db336370.1483630849.git.dcaratti@redhat.com>
References: <cover.1483630849.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S . Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762976AbdAERAI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 12:00:08 -0500
In-Reply-To: <cover.1483630849.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LIBCRC32C is needed to compute crc32c on SCTP packets.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/sched/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 87956a7..a9aa38d 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -707,6 +707,7 @@ config NET_ACT_SKBEDIT
 config NET_ACT_CSUM
         tristate "Checksum Updating"
         depends on NET_CLS_ACT && INET
+        select LIBCRC32C
         ---help---
 	  Say Y here to update some common checksum after some direct
 	  packet alterations.
-- 
2.7.4
