From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/8] iproute2: Make the addr argument of ll_addr_n2a const
Date: Fri, 13 Mar 2015 13:52:45 -0500
Message-ID: <87wq2krapu.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41965 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbbCMS41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 14:56:27 -0400
In-Reply-To: <87bnjwspek.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 13:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This avoids build warnings when AF_PACKET support is added
to rt_addr_n2a.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/rt_names.h | 2 +-
 lib/ll_addr.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/rt_names.h b/include/rt_names.h
index c0ea4f982904..921be0607b51 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -22,7 +22,7 @@ int inet_proto_a2n(const char *buf);
 
 
 const char * ll_type_n2a(int type, char *buf, int len);
-const char *ll_addr_n2a(unsigned char *addr, int alen,
+const char *ll_addr_n2a(const unsigned char *addr, int alen,
 			int type, char *buf, int blen);
 int ll_addr_a2n(char *lladdr, int len, const char *arg);
 
diff --git a/lib/ll_addr.c b/lib/ll_addr.c
index c12ab075c4a9..2ce9abfbb8c6 100644
--- a/lib/ll_addr.c
+++ b/lib/ll_addr.c
@@ -29,7 +29,7 @@
 #include "utils.h"
 
 
-const char *ll_addr_n2a(unsigned char *addr, int alen, int type, char *buf, int blen)
+const char *ll_addr_n2a(const unsigned char *addr, int alen, int type, char *buf, int blen)
 {
 	int i;
 	int l;
-- 
2.2.1
