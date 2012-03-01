From: "Christoph J. Thompson" <cjsthompson@gmail.com>
Subject: [PATCH 1/4] iproute2 - Don't hardcode the path to config files.
 Allows using an alternate path for config files.
Date: Thu, 1 Mar 2012 17:44:43 +0100
Message-ID: <20120301164439.GA24257@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36787 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400Ab2CAQoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 11:44:34 -0500
Received: by wibhm2 with SMTP id hm2so53148wib.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 08:44:33 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	modified:   lib/rt_names.c

Signed-off-by: Christoph J. Thompson <cjsthompson@gmail.com>
---
 lib/rt_names.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/rt_names.c b/lib/rt_names.c
index a290021..52ecdb2 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -23,6 +23,10 @@
 
 #include "rt_names.h"
 
+#ifndef CONFDIR
+#define CONFDIR "/etc/iproute2"
+#endif
+
 struct rtnl_hash_entry {
 	struct rtnl_hash_entry *next;
 	char *			name;
@@ -129,7 +133,7 @@ static int rtnl_rtprot_init;
 static void rtnl_rtprot_initialize(void)
 {
 	rtnl_rtprot_init = 1;
-	rtnl_tab_initialize("/etc/iproute2/rt_protos",
+	rtnl_tab_initialize(CONFDIR "/rt_protos",
 			    rtnl_rtprot_tab, 256);
 }
 
@@ -196,7 +200,7 @@ static void rtnl_rtscope_initialize(void)
 	rtnl_rtscope_tab[254] = "host";
 	rtnl_rtscope_tab[253] = "link";
 	rtnl_rtscope_tab[200] = "site";
-	rtnl_tab_initialize("/etc/iproute2/rt_scopes",
+	rtnl_tab_initialize(CONFDIR "/rt_scopes",
 			    rtnl_rtscope_tab, 256);
 }
 
@@ -259,7 +263,7 @@ static int rtnl_rtrealm_init;
 static void rtnl_rtrealm_initialize(void)
 {
 	rtnl_rtrealm_init = 1;
-	rtnl_tab_initialize("/etc/iproute2/rt_realms",
+	rtnl_tab_initialize(CONFDIR "/rt_realms",
 			    rtnl_rtrealm_tab, 256);
 }
 
@@ -328,7 +332,7 @@ static int rtnl_rttable_init;
 static void rtnl_rttable_initialize(void)
 {
 	rtnl_rttable_init = 1;
-	rtnl_hash_initialize("/etc/iproute2/rt_tables",
+	rtnl_hash_initialize(CONFDIR "/rt_tables",
 			     rtnl_rttable_hash, 256);
 }
 
@@ -396,7 +400,7 @@ static int rtnl_rtdsfield_init;
 static void rtnl_rtdsfield_initialize(void)
 {
 	rtnl_rtdsfield_init = 1;
-	rtnl_tab_initialize("/etc/iproute2/rt_dsfield",
+	rtnl_tab_initialize(CONFDIR "/rt_dsfield",
 			    rtnl_rtdsfield_tab, 256);
 }
 
-- 
1.7.4.4


-- 
Jabber: heimdal@jabber.org
