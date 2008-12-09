From: holger@eitzenberger.org
Subject: [patch 7/7] bonding: turn all bond_parm_tbls const
Date: Tue, 09 Dec 2008 21:07:57 +0100
Message-ID: <20081209201452.354289223@eitzenberger.org>
References: <20081209200750.490739902@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:51856 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbYLIUO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 15:14:56 -0500
Content-Disposition: inline; filename=bonding-make-bond_parm_tbls-const.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn all bond_parm_tbls const.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: bonding-2.6-out/drivers/net/bonding/bond_main.c
===================================================================
--- bonding-2.6-out.orig/drivers/net/bonding/bond_main.c	2008-12-09 20:56:11.000000000 +0100
+++ bonding-2.6-out/drivers/net/bonding/bond_main.c	2008-12-09 20:57:14.000000000 +0100
@@ -162,13 +162,13 @@
 static int lacp_fast	= 0;
 
 
-struct bond_parm_tbl bond_lacp_tbl[] = {
+const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	"slow",		AD_LACP_SLOW},
 {	"fast",		AD_LACP_FAST},
 {	NULL,		-1},
 };
 
-struct bond_parm_tbl bond_mode_tbl[] = {
+const struct bond_parm_tbl bond_mode_tbl[] = {
 {	"balance-rr",		BOND_MODE_ROUNDROBIN},
 {	"active-backup",	BOND_MODE_ACTIVEBACKUP},
 {	"balance-xor",		BOND_MODE_XOR},
@@ -179,14 +179,14 @@
 {	NULL,			-1},
 };
 
-struct bond_parm_tbl xmit_hashtype_tbl[] = {
+const struct bond_parm_tbl xmit_hashtype_tbl[] = {
 {	"layer2",		BOND_XMIT_POLICY_LAYER2},
 {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
 {	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
 {	NULL,			-1},
 };
 
-struct bond_parm_tbl arp_validate_tbl[] = {
+const struct bond_parm_tbl arp_validate_tbl[] = {
 {	"none",			BOND_ARP_VALIDATE_NONE},
 {	"active",		BOND_ARP_VALIDATE_ACTIVE},
 {	"backup",		BOND_ARP_VALIDATE_BACKUP},
@@ -194,7 +194,7 @@
 {	NULL,			-1},
 };
 
-struct bond_parm_tbl fail_over_mac_tbl[] = {
+const struct bond_parm_tbl fail_over_mac_tbl[] = {
 {	"none",			BOND_FOM_NONE},
 {	"active",		BOND_FOM_ACTIVE},
 {	"follow",		BOND_FOM_FOLLOW},
Index: bonding-2.6-out/drivers/net/bonding/bonding.h
===================================================================
--- bonding-2.6-out.orig/drivers/net/bonding/bonding.h	2008-12-09 20:56:11.000000000 +0100
+++ bonding-2.6-out/drivers/net/bonding/bonding.h	2008-12-09 20:57:14.000000000 +0100
@@ -345,11 +345,11 @@
 
 /* exported from bond_main.c */
 extern struct list_head bond_dev_list;
-extern struct bond_parm_tbl bond_lacp_tbl[];
-extern struct bond_parm_tbl bond_mode_tbl[];
-extern struct bond_parm_tbl xmit_hashtype_tbl[];
-extern struct bond_parm_tbl arp_validate_tbl[];
-extern struct bond_parm_tbl fail_over_mac_tbl[];
+extern const struct bond_parm_tbl bond_lacp_tbl[];
+extern const struct bond_parm_tbl bond_mode_tbl[];
+extern const struct bond_parm_tbl xmit_hashtype_tbl[];
+extern const struct bond_parm_tbl arp_validate_tbl[];
+extern const struct bond_parm_tbl fail_over_mac_tbl[];
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 void bond_send_unsolicited_na(struct bonding *bond);

-- 
