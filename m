From: Eric Garver <e@erig.me>
Subject: [PATCH] Documentation: ip-sysctl.txt: clarify secure_redirects
Date: Thu, 26 May 2016 12:28:05 -0400
Message-ID: <1464280085-21851-1-git-send-email-e@erig.me>
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbcEZQ2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 12:28:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify how secure_redirects works. Mention that RFC1122 always applies.

Signed-off-by: Eric Garver <e@erig.me>
---
 Documentation/networking/ip-sysctl.txt | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6c7f365b1515..9ae929395b24 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1036,15 +1036,17 @@ proxy_arp_pvlan - BOOLEAN
 
 shared_media - BOOLEAN
 	Send(router) or accept(host) RFC1620 shared media redirects.
-	Overrides ip_secure_redirects.
+	Overrides secure_redirects.
 	shared_media for the interface will be enabled if at least one of
 	conf/{all,interface}/shared_media is set to TRUE,
 	it will be disabled otherwise
 	default TRUE
 
 secure_redirects - BOOLEAN
-	Accept ICMP redirect messages only for gateways,
-	listed in default gateway list.
+	Accept ICMP redirect messages only to gateways listed in the
+	interface's current gateway list. Even if disabled, RFC1122 redirect
+	rules still apply.
+	Overridden by shared_media.
 	secure_redirects for the interface will be enabled if at least one of
 	conf/{all,interface}/secure_redirects is set to TRUE,
 	it will be disabled otherwise
-- 
2.5.5
