From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [LLC]: Kill static inline llc_addrany
Date: Fri, 29 Feb 2008 18:13:16 +0200
Message-ID: <1204301596-15568-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41074 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759807AbYB2QNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 11:13:18 -0500
In-Reply-To: <1204301596-15568-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch:
$ git-grep llc_addrany | wc -l
0

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 include/net/llc_if.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/net/llc_if.h b/include/net/llc_if.h
index c608812..b595a00 100644
--- a/include/net/llc_if.h
+++ b/include/net/llc_if.h
@@ -74,11 +74,6 @@ static inline int llc_mac_null(const u8 *mac)
 	return is_zero_ether_addr(mac);
 }
=20
-static inline int llc_addrany(const struct llc_addr *addr)
-{
-	return llc_mac_null(addr->mac) && !addr->lsap;
-}
-
 static inline int llc_mac_multicast(const u8 *mac)
 {
 	return is_multicast_ether_addr(mac);
--=20
1.5.2.2

