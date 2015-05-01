From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] man ip-link: Add deleting links by group
Date: Fri,  1 May 2015 21:46:41 +0300
Message-ID: <1430506001-10229-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:33836 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbEASrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:47:07 -0400
Received: by lbcga7 with SMTP id ga7so69934969lbc.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:47:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Indicate possibility deleting virtual links by group.

Also changed the alignment of 'ip link delete' args
descriptions, to look like similary to 'ip link set'.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 5ad372c..0dfcb2e 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -78,7 +78,10 @@ ip-link \- network device configuration
 .BR ipvlan " ]"
 
 .ti -8
-.BI "ip link delete " DEVICE
+.BR "ip link delete " {
+.IR DEVICE " | "
+.BI "group " GROUP
+}
 .BI type " TYPE"
 .RI "[ " ARGS " ]"
 
@@ -588,15 +591,19 @@ the following additional arguments are supported:
 - specifies the mode (datagram or connected) to use.
 
 .SS ip link delete - delete virtual link
-.I DEVICE
-specifies the virtual  device to act operate on.
-.I TYPE
-specifies the type of the device.
-
 
 .TP
 .BI dev " DEVICE "
-specifies the physical device to act operate on.
+specifies the virtual device to act operate on.
+
+.TP
+.BI group " GROUP "
+specifies the group of virtual links to delete. Group 0 is not allowed to be
+deleted since it is the default group.
+
+.TP
+.BI type " TYPE "
+specifies the type of the device.
 
 .SS ip link set - change device attributes
 
-- 
2.3.1
