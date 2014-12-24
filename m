From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: [PATCH iproute2] ip: extend "ip-address" man page to reflect the
 recent flag extensions
Date: Wed, 24 Dec 2014 23:11:50 +0100
Message-ID: <549B3A26.6010601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:37507 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbaLXWL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 17:11:58 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so11901395wgh.26
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 14:11:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend "ip-address" man page to reflect the recent extension of
allowing to list addresses with flags tentative, deprecated, dadfailed
not being set.

Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
---
 man/man8/ip-address.8.in | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 3cfc56a..d33b1ed 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -50,8 +50,9 @@ ip-address \- protocol address management
 
 .ti -8
 .IR FLAG " := "
-.RB "[ " permanent " | " dynamic " | " secondary " | " primary " | "\
-tentative " | " deprecated " | " dadfailed " | " temporary " ]"
+.RB "[ " permanent " | " dynamic " | " secondary " | " primary " | \
+[ - ] " tentative " | [ - ] " deprecated " | [ - ] " dadfailed " | "\
+temporary " ]"
 
 .SH "DESCRIPTION"
 The
@@ -178,15 +179,29 @@ addresses.
 address detection.
 
 .TP
+.B -tentative
+(IPv6 only) only list addresses which are not in the process of
+duplicate address detection currently.
+
+.TP
 .B deprecated
 (IPv6 only) only list deprecated addresses.
 
 .TP
+.B -deprecated
+(IPv6 only) only list addresses not being deprecated.
+
+.TP
 .B dadfailed
 (IPv6 only) only list addresses which have failed duplicate
 address detection.
 
 .TP
+.B -dadfailed
+(IPv6 only) only list addresses which have not failed duplicate
+address detection.
+
+.TP
 .B temporary
 (IPv6 only) only list temporary addresses.
 
-- 
2.2.1
