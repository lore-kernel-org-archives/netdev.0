From: paul.moore@hp.com
Subject: [PATCH 03/13] NetLabel: change netlbl_secattr_init() to return void
Date: Fri, 17 Nov 2006 17:38:45 -0500
Message-ID: <20061117224332.533289000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:21909 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1755991AbWKQWng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:36 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-secattr_retval
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

The netlbl_secattr_init() function would always return 0 making it pointless
to have a return value.  This patch changes the function to return void.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/netlabel.h |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

Index: net-2.6.20_netlabel-base-work/include/net/netlabel.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/include/net/netlabel.h
+++ net-2.6.20_netlabel-base-work/include/net/netlabel.h
@@ -169,14 +169,12 @@ static inline void netlbl_secattr_cache_
  * @secattr: the struct to initialize
  *
  * Description:
- * Initialize an already allocated netlbl_lsm_secattr struct.  Returns zero on
- * success, negative values on error.
+ * Initialize an already allocated netlbl_lsm_secattr struct.
  *
  */
-static inline int netlbl_secattr_init(struct netlbl_lsm_secattr *secattr)
+static inline void netlbl_secattr_init(struct netlbl_lsm_secattr *secattr)
 {
 	memset(secattr, 0, sizeof(*secattr));
-	return 0;
 }
 
 /**

--
paul moore
linux security @ hp
