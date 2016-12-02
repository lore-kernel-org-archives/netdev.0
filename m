From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 18/18] ss: unix_show: No need to initialize members of calloc'ed structs
Date: Fri,  2 Dec 2016 11:40:02 +0100
Message-ID: <20161202104002.17310-19-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41250 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934016AbcLBKku (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:40:50 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c72aba7e65ad3..f23aa6be33174 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3066,8 +3066,6 @@ static int unix_show(struct filter *f)
 
 		if (!(u = calloc(1, sizeof(*u))))
 			break;
-		u->name = NULL;
-		u->peer_name = NULL;
 
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
 			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
-- 
2.10.0
