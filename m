From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next 2/2] iproute2: ip-route.8.in: Add expires option for ip route
Date: Fri, 25 Dec 2015 11:12:16 +0800
Message-ID: <1451013136-13251-2-git-send-email-liuhangbin@gmail.com>
References: <1451013136-13251-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Xin Long <lucien.xin@gmail.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33613 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbLYDMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 22:12:31 -0500
Received: by mail-pa0-f68.google.com with SMTP id pv5so3335055pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 19:12:31 -0800 (PST)
In-Reply-To: <1451013136-13251-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 man/man8/ip-route.8.in | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 5b45bc2..c5494f8 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -130,7 +130,9 @@ replace " } "
 .B  congctl
 .IR NAME " ] [ "
 .B  pref
-.IR PREF " ]"
+.IR PREF " ] [ "
+.B  expires
+.IR TIME " ]"
 
 .ti -8
 .IR TYPE " := [ "
@@ -593,6 +595,12 @@ Discovery messages. Namely:
 .RE
 
 .TP
+.BI expires " TIME " "(4.4+ only)"
+the route will be deleted after the expires time.
+.B Only
+support IPv6 at present.
+
+.TP
 ip route delete
 delete route
 .RS
-- 
2.4.3
