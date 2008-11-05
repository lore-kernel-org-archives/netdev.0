From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH] ehea: Fix some whitespace issues
Date: Wed, 5 Nov 2008 13:18:21 +0100
Message-ID: <200811051318.21579.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:60029 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbYKEMS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 07:18:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes some trailing whitespaces and spaces before tabs.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>
---
diff -Nurp -X dontdiff linux-2.6.28-rc3/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.28-rc3/drivers/net/ehea/ehea.h	2008-11-02 23:17:19.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-11-05 10:10:14.563107976 +0100
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0095"
+#define DRV_VERSION	"EHEA_0096"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.28-rc3/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.28-rc3/drivers/net/ehea/ehea_qmr.c	2008-11-02 23:17:19.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2008-11-05 10:10:14.563107976 +0100
@@ -653,7 +653,7 @@ static int ehea_update_busmap(unsigned l
 		int top = ehea_calc_index(i, EHEA_TOP_INDEX_SHIFT);
 		int dir = ehea_calc_index(i, EHEA_DIR_INDEX_SHIFT);
 		int idx = i & EHEA_INDEX_MASK;
-		
+
 		if (add) {
 			int ret = ehea_init_bmap(ehea_bmap, top, dir);
 			if (ret)
@@ -780,7 +780,7 @@ void ehea_destroy_busmap(void)
 
 	kfree(ehea_bmap);
 	ehea_bmap = NULL;
-out_destroy:	
+out_destroy:
 	mutex_unlock(&ehea_busmap_mutex);
 }
 
@@ -858,10 +858,10 @@ static u64 ehea_reg_mr_sections(int top,
 	for (idx = 0; idx < EHEA_MAP_ENTRIES; idx++) {
 		if (!ehea_bmap->top[top]->dir[dir]->ent[idx])
 			continue;
-		
+
 		hret = ehea_reg_mr_section(top, dir, idx, pt, adapter, mr);
 		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
-			    	return hret;
+			return hret;
 	}
 	return hret;
 }
@@ -879,7 +879,7 @@ static u64 ehea_reg_mr_dir_sections(int 
 
 		hret = ehea_reg_mr_sections(top, dir, pt, adapter, mr);
 		if ((hret != H_SUCCESS) && (hret != H_PAGE_REGISTERED))
-			    	return hret;
+			return hret;
 	}
 	return hret;
 }
