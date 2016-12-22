From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 2/2] tc/m_tunnel_key: Add to the usage encapsulation dest UDP port
Date: Thu, 22 Dec 2016 10:14:41 +0200
Message-ID: <1482394481-19624-3-git-send-email-hadarh@mellanox.com>
References: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34902 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1765053AbcLVJK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 04:10:26 -0500
In-Reply-To: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tunnel key set parameters includes also dest UDP port, add it to the
usage.

Fixes: 449c709c3868 ("tc/m_tunnel_key: Add dest UDP port to tunnel key action")
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reported-by: Simon Horman <simon.horman@netronome.com>
---
 tc/m_tunnel_key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_tunnel_key.c b/tc/m_tunnel_key.c
index 58a3042..3ceec1c 100644
--- a/tc/m_tunnel_key.c
+++ b/tc/m_tunnel_key.c
@@ -22,7 +22,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: tunnel_key unset\n");
-	fprintf(stderr, "       tunnel_key set id TUNNELID src_ip IP dst_ip IP\n");
+	fprintf(stderr, "       tunnel_key set id TUNNELID src_ip IP dst_ip IP dst_port UDP_PORT\n");
 }
 
 static void usage(void)
-- 
1.8.3.1
