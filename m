From: takis@issaris.org
Subject: [PATCH 1/4] net: Removing useless casts
Date: Fri, 21 Jul 2006 15:45:50 +0200
Message-ID: <20060721134550.GA27097@issaris.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: per.liden@ericsson.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmx009.isp.belgacom.be ([195.238.5.4]:33158 "EHLO
	outmx009.isp.belgacom.be") by vger.kernel.org with ESMTP
	id S1750722AbWGUNo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 09:44:58 -0400
Received: from outmx009.isp.belgacom.be (localhost [127.0.0.1])
        by outmx009.isp.belgacom.be (8.12.11.20060308/8.12.11/Skynet-OUT-2.22) with ESMTP id k6LDisXU026883
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2006 15:44:54 +0200
        (envelope-from <takis@issaris.org>)
To: linux-kernel@vger.kernel.og
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Panagiotis Issaris <takis@issaris.org>

Removing useless casts

Signed-off-by: Panagiotis Issaris <takis@issaris.org>
---
 net/tipc/discover.c |    2 +-
 net/tipc/ref.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 2b84412..ee94de9 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -295,7 +295,7 @@ struct link_req *tipc_disc_init_link_req
 {
 	struct link_req *req;
 
-	req = (struct link_req *)kmalloc(sizeof(*req), GFP_ATOMIC);
+	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req)
 		return NULL;
 
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 596d3c8..e6d6ae2 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -79,7 +79,7 @@ int tipc_ref_table_init(u32 requested_si
 	while (sz < requested_size) {
 		sz <<= 1;
 	}
-	table = (struct reference *)vmalloc(sz * sizeof(struct reference));
+	table = vmalloc(sz * sizeof(*table));
 	if (table == NULL)
 		return -ENOMEM;
 
-- 
1.4.2.rc1.ge7a0-dirty

