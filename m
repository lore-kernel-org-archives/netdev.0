From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netlabel: add missing inline to stub
Date: Mon, 11 Aug 2014 08:22:35 -0700
Message-ID: <20140811082235.15c800ae@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:52081 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbaHKPWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 11:22:40 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so11356112pab.0
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 08:22:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This stub like all the nearby stubs should be inline.
This fixes a sparse warning about defined but never used.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/net/netlabel.h	2014-08-09 08:39:57.704179307 -0700
+++ b/include/net/netlabel.h	2014-08-11 07:54:01.058097452 -0700
@@ -524,10 +524,10 @@ static inline int netlbl_catmap_setrng(s
 {
 	return 0;
 }
-static int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
-				 u32 offset,
-				 unsigned long bitmap,
-				 gfp_t flags)
+static inline int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
+					u32 offset,
+					unsigned long bitmap,
+					gfp_t flags)
 {
 	return 0;
 }
