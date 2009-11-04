From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] tc: remove dlfcn.h from files that dont need it
Date: Wed,  4 Nov 2009 09:26:34 -0500
Message-ID: <1257344795-8665-2-git-send-email-vapier@gentoo.org>
References: <1257344795-8665-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46053 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756467AbZKDOZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 09:25:17 -0500
In-Reply-To: <1257344795-8665-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bunch of source files look like they're copy & pasted from other files,
and some include header files that they don't actually need.  Since dlfcn
has very specific usage (and is a pain on a static-only system), drop it
where it isn't really needed.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tc/em_cmp.c   |    1 -
 tc/em_meta.c  |    1 -
 tc/em_nbyte.c |    1 -
 tc/em_u32.c   |    1 -
 tc/m_nat.c    |    1 -
 tc/m_xt.c     |    1 -
 6 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tc/em_cmp.c b/tc/em_cmp.c
index ce72a42..6addce0 100644
--- a/tc/em_cmp.c
+++ b/tc/em_cmp.c
@@ -18,7 +18,6 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
-#include <dlfcn.h>
 #include <errno.h>
 
 #include "m_ematch.h"
diff --git a/tc/em_meta.c b/tc/em_meta.c
index ee6034f..033e29f 100644
--- a/tc/em_meta.c
+++ b/tc/em_meta.c
@@ -18,7 +18,6 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
-#include <dlfcn.h>
 #include <errno.h>
 
 #include "m_ematch.h"
diff --git a/tc/em_nbyte.c b/tc/em_nbyte.c
index 242c361..87f3e9d 100644
--- a/tc/em_nbyte.c
+++ b/tc/em_nbyte.c
@@ -18,7 +18,6 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
-#include <dlfcn.h>
 #include <errno.h>
 
 #include "m_ematch.h"
diff --git a/tc/em_u32.c b/tc/em_u32.c
index 402bea0..21ed70f 100644
--- a/tc/em_u32.c
+++ b/tc/em_u32.c
@@ -18,7 +18,6 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
-#include <dlfcn.h>
 #include <errno.h>
 
 #include "m_ematch.h"
diff --git a/tc/m_nat.c b/tc/m_nat.c
index 6e7fd05..01ec032 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -19,7 +19,6 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
-#include <dlfcn.h>
 #include "utils.h"
 #include "tc_util.h"
 #include <linux/tc_act/tc_nat.h>
diff --git a/tc/m_xt.c b/tc/m_xt.c
index 0fe6189..0c7ec60 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -25,7 +25,6 @@
 #include "tc_util.h"
 #include <linux/tc_act/tc_ipt.h>
 #include <stdio.h>
-#include <dlfcn.h>
 #include <getopt.h>
 #include <errno.h>
 #include <string.h>
-- 
1.6.5.1

