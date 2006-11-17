From: paul.moore@hp.com
Subject: [PATCH 01/13] NetLabel: use gfp_t instead of int where it makes sense
Date: Fri, 17 Nov 2006 17:38:43 -0500
Message-ID: <20061117224331.250734000@hp.com>
References: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org, Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:48025 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755984AbWKQWne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:34 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-secattr_gfpflags
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

There were a few places in the NetLabel code where the int type was being used
instead of the gfp_t type, this patch corrects this mistake.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/netlabel.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: net-2.6.20_netlabel-base-work/include/net/netlabel.h
===================================================================
--- net-2.6.20_netlabel-base-work.orig/include/net/netlabel.h
+++ net-2.6.20_netlabel-base-work/include/net/netlabel.h
@@ -205,7 +205,7 @@ static inline void netlbl_secattr_destro
  * pointer on success, or NULL on failure.
  *
  */
-static inline struct netlbl_lsm_secattr *netlbl_secattr_alloc(int flags)
+static inline struct netlbl_lsm_secattr *netlbl_secattr_alloc(gfp_t flags)
 {
 	return kzalloc(sizeof(struct netlbl_lsm_secattr), flags);
 }

--
paul moore
linux security @ hp
