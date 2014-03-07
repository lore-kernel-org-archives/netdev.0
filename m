From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 1/2] iproute2: use named constants instead of number literals to fill rtnl_rtscope_tab
Date: Fri,  7 Mar 2014 19:21:36 +0900
Message-ID: <1394187697-1147-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26663 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148AbaCGKVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 05:21:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 lib/rt_names.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index 67e4c49..b005a64 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -194,10 +194,10 @@ static int rtnl_rtscope_init;
 static void rtnl_rtscope_initialize(void)
 {
 	rtnl_rtscope_init = 1;
-	rtnl_rtscope_tab[255] = "nowhere";
-	rtnl_rtscope_tab[254] = "host";
-	rtnl_rtscope_tab[253] = "link";
-	rtnl_rtscope_tab[200] = "site";
+	rtnl_rtscope_tab[RT_SCOPE_NOWHERE] = "nowhere";
+	rtnl_rtscope_tab[RT_SCOPE_HOST]    = "host";
+	rtnl_rtscope_tab[RT_SCOPE_LINK]    = "link";
+	rtnl_rtscope_tab[RT_SCOPE_SITE]    = "site";
 	rtnl_tab_initialize(CONFDIR "/rt_scopes",
 			    rtnl_rtscope_tab, 256);
 }
-- 
1.8.5.3
