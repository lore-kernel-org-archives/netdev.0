From: Hisao Tanabe <xtanabe@gmail.com>
Subject: [PATCH net-next] ipv4: Use predefined value for readability
Date: Sun, 27 Apr 2014 19:03:45 +0900
Message-ID: <1398593025-597-1-git-send-email-xtanabe@gmail.com>
Cc: Hisao Tanabe <xtanabe@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46796 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbaD0KDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 06:03:50 -0400
Received: by mail-pb0-f52.google.com with SMTP id rp16so907030pbb.39
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 03:03:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hisao Tanabe <xtanabe@gmail.com>
---
 net/ipv4/ip_options.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index f4ab72e..5e7aece 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -364,7 +364,7 @@ int ip_options_compile(struct net *net,
 			}
 			if (optptr[2] <= optlen) {
 				unsigned char *timeptr = NULL;
-				if (optptr[2]+3 > optptr[1]) {
+				if (optptr[2]+3 > optlen) {
 					pp_ptr = optptr + 2;
 					goto error;
 				}
@@ -376,7 +376,7 @@ int ip_options_compile(struct net *net,
 					optptr[2] += 4;
 					break;
 				case IPOPT_TS_TSANDADDR:
-					if (optptr[2]+7 > optptr[1]) {
+					if (optptr[2]+7 > optlen) {
 						pp_ptr = optptr + 2;
 						goto error;
 					}
@@ -390,7 +390,7 @@ int ip_options_compile(struct net *net,
 					optptr[2] += 8;
 					break;
 				case IPOPT_TS_PRESPEC:
-					if (optptr[2]+7 > optptr[1]) {
+					if (optptr[2]+7 > optlen) {
 						pp_ptr = optptr + 2;
 						goto error;
 					}
-- 
1.9.2
