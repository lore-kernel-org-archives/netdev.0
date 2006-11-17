From: paul.moore@hp.com
Subject: [PATCH 09/13] NetLabel: use the correct CIPSOv4 MLS label limits
Date: Fri, 17 Nov 2006 17:38:51 -0500
Message-ID: <20061117224336.024043000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:55705 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755985AbWKQWni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:38 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_mlslimits
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The CIPSOv4 engine currently has MLS label limits which are slightly larger
than what the draft allows.  This is not a major problem due to the current
implementation but we should fix this so it doesn't bite us later.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/cipso_ipv4.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6.20_netlabel-base-work/include/net/cipso_ipv4.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/include/net/cipso_ipv4.h
+++ net-2.6.20_netlabel-base-work/include/net/cipso_ipv4.h
@@ -58,10 +58,10 @@
 #define CIPSO_V4_MAP_PASS             2
 
 /* limits */
-#define CIPSO_V4_MAX_REM_LVLS         256
+#define CIPSO_V4_MAX_REM_LVLS         255
 #define CIPSO_V4_INV_LVL              0x80000000
 #define CIPSO_V4_MAX_LOC_LVLS         (CIPSO_V4_INV_LVL - 1)
-#define CIPSO_V4_MAX_REM_CATS         65536
+#define CIPSO_V4_MAX_REM_CATS         65534
 #define CIPSO_V4_INV_CAT              0x80000000
 #define CIPSO_V4_MAX_LOC_CATS         (CIPSO_V4_INV_CAT - 1)
 

--
paul moore
linux security @ hp
