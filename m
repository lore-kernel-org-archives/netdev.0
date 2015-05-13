From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Remove extra GROUP explanation
Date: Wed, 13 May 2015 18:03:51 +0300
Message-ID: <1431529431-23916-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33533 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964925AbbEMPEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 11:04:32 -0400
Received: by wicmx19 with SMTP id mx19so13081092wic.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 08:04:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Remove double explanation of GROUP option from 'ip link set' section.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 823246f..714aab4 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -714,12 +714,6 @@ tool can be used. But it allows to change network namespace only for physical de
 give the device a symbolic name for easy reference.
 
 .TP
-.BI group " GROUP"
-specify the group the device belongs to.
-The available groups are listed in file
-.BR "@SYSCONFDIR@/group" .
-
-.TP
 .BI vf " NUM"
 specify a Virtual Function device to be configured. The associated PF device
 must be specified using the
@@ -867,7 +861,7 @@ specifies which help of link type to dislpay.
 .SS
 .I GROUP
 may be a number or a string from the file
-.B /etc/iproute2/group
+.B @SYSCONFDIR@/group
 which can be manually filled.
 
 .SH "EXAMPLES"
-- 
2.3.1
