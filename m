From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] iproute2: fix typo in help message.
Date: Mon, 20 Aug 2012 14:28:47 +0800
Message-ID: <1345444127-27932-1-git-send-email-lw@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Li Wei <lw@cn.fujitsu.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15474 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752839Ab2HTG3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 02:29:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 bridge/fdb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 2bbdaa6..c6aa08e 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -239,6 +239,6 @@ int do_fdb(int argc, char **argv)
 	} else
 		return fdb_show(0, NULL);
 
-	fprintf(stderr, "Command \"%s\" is unknown, try \"ip neigh help\".\n", *argv);
+	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
 	exit(-1);
 }
-- 
1.7.10.1
