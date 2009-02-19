From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH 6/7] fcoe: remove ETH_P_FCOE from fc_fcoe.h
Date: Thu, 19 Feb 2009 12:50:23 -0700
Message-ID: <20090219195022.22270.8543.stgit.yi.zou@intel.com>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26113 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755849AbZBSU5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 15:57:31 -0500
In-Reply-To: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to have ETH_P_FCOE in fc_fcoe.h as it is now defined in if_ether.h

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/scsi/fc/fc_fcoe.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/include/scsi/fc/fc_fcoe.h b/include/scsi/fc/fc_fcoe.h
index f271d9c..ccb3dbe 100644
--- a/include/scsi/fc/fc_fcoe.h
+++ b/include/scsi/fc/fc_fcoe.h
@@ -25,13 +25,6 @@
  */
 
 /*
- * The FCoE ethertype eventually goes in net/if_ether.h.
- */
-#ifndef ETH_P_FCOE
-#define	ETH_P_FCOE	0x8906		/* FCOE ether type */
-#endif
-
-/*
  * FC_FCOE_OUI hasn't been standardized yet.   XXX TBD.
  */
 #ifndef FC_FCOE_OUI

