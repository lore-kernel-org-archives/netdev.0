From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 18/18] ss: unix_show: No need to initialize members of calloc'ed structs
Date: Fri, 11 Nov 2016 14:10:14 +0100
Message-ID: <20161111131014.21865-19-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53646 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756648AbcKKNLW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:22 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 6e669f7b0593c..1e3ccf28c4e84 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2877,8 +2877,6 @@ static int unix_show(struct filter *f)
 
 		if (!(u = calloc(1, sizeof(*u))))
 			break;
-		u->name = NULL;
-		u->peer_name = NULL;
 
 		if (sscanf(buf, "%x: %x %x %x %x %x %d %s",
 			   &u->rport, &u->rq, &u->wq, &flags, &u->type,
-- 
2.10.0
