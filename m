From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 2/3] pktgen: give user result when disable vlan/svlan
Date: Thu, 15 May 2014 17:46:36 +0800
Message-ID: <1400147197-22445-2-git-send-email-liuhangbin@gmail.com>
References: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com>
Cc: Francesco Fondelli <francesco.fondelli@gmail.com>,
	netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:60969 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaEOJrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:47:02 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so889752pbc.28
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 02:47:01 -0700 (PDT)
In-Reply-To: <1400147197-22445-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/core/pktgen.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index dcf367f..1809bdf 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1573,8 +1573,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->vlan_id = 0xffff; /* turn off VLAN/SVLAN */
 			pkt_dev->svlan_id = 0xffff;
 
-			if (debug)
-				pr_debug("VLAN/SVLAN turned off\n");
+			sprintf(pg_result, "OK: VLAN/SVLAN turned off");
 		}
 		return count;
 	}
@@ -1629,8 +1628,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		} else {
 			pkt_dev->svlan_id = 0xffff;
 
-			if (debug)
-				pr_debug("SVLAN turned off\n");
+			sprintf(pg_result, "OK: SVLAN turned off");
 		}
 		return count;
 	}
-- 
1.8.1.4
