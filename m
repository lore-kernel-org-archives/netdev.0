From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] ip: update policy routing config help
Date: Wed, 11 Oct 2017 20:10:31 -0700
Message-ID: <20171012031031.8415-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:52289 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdJLDKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:10:47 -0400
Received: by mail-pf0-f173.google.com with SMTP id e64so3027145pfk.9
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 20:10:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel config help for policy routing was still pointing at
an ancient document from 2000 that refers to Linux 2.1. Update it
to point to something that is at least occasionally updated.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv4/Kconfig | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 91a2557942fa..f48fe6fc7e8c 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -70,11 +70,9 @@ config IP_MULTIPLE_TABLES
 	  address into account. Furthermore, the TOS (Type-Of-Service) field
 	  of the packet can be used for routing decisions as well.
 
-	  If you are interested in this, please see the preliminary
-	  documentation at <http://www.compendium.com.ar/policy-routing.txt>
-	  and <ftp://post.tepkom.ru/pub/vol2/Linux/docs/advanced-routing.tex>.
-	  You will need supporting software from
-	  <ftp://ftp.tux.org/pub/net/ip-routing/>.
+	  If you need more information, see the Linux Advanced
+	  Routing and Traffic Control documentation at
+	  <http://lartc.org/howto/lartc.rpdb.html>
 
 	  If unsure, say N.
 
-- 
2.11.0
