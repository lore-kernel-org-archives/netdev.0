From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 1/2] net headers: cleanup dcbnl.h
Date: Fri, 27 Feb 2009 12:01:36 -0800
Message-ID: <20090227200136.31557.53143.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17896 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbZB0UBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 15:01:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) add an include for <linux/types.h>
2) change dcbmsg.dcb_family from unsigned char to __u8 to be more
   consistent with use of kernel types

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 include/linux/dcbnl.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index b0ef274..7d2e100 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -20,10 +20,12 @@
 #ifndef __LINUX_DCBNL_H__
 #define __LINUX_DCBNL_H__
 
+#include <linux/types.h>
+
 #define DCB_PROTO_VERSION 1
 
 struct dcbmsg {
-	unsigned char      dcb_family;
+	__u8               dcb_family;
 	__u8               cmd;
 	__u16              dcb_pad;
 };

