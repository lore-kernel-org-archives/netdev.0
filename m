From: holger@eitzenberger.org
Subject: [patch 5/7] bonding: remove duplicate declarations
Date: Tue, 09 Dec 2008 21:07:55 +0100
Message-ID: <20081209201449.891457437@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:58533 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbYLIUT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:19:58 -0500
Content-Disposition: inline; filename=bonding-remove-duplicate-declarations.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some declarations from bonding.c as they are declared in bonding.h
already.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6/drivers/net/bonding/bond_sysfs.c
===================================================================
--- bonding-2.6.orig/drivers/net/bonding/bond_sysfs.c	2008-12-05 23:21:10.000000000 +0100
+++ bonding-2.6/drivers/net/bonding/bond_sysfs.c	2008-12-05 23:23:12.000000000 +0100
@@ -43,15 +43,8 @@
 
 /*---------------------------- Declarations -------------------------------*/
 
-
-extern struct list_head bond_dev_list;
 extern struct bond_params bonding_defaults;
-extern struct bond_parm_tbl bond_mode_tbl[];
-extern struct bond_parm_tbl bond_lacp_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
-extern struct bond_parm_tbl xmit_hashtype_tbl[];
-extern struct bond_parm_tbl arp_validate_tbl[];
-extern struct bond_parm_tbl fail_over_mac_tbl[];
 
 static int expected_refcount = -1;
 /*--------------------------- Data Structures -----------------------------*/

-- 
