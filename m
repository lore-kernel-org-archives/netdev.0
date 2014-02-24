From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/13] pfkey: fix SADB_X_EXT_FILTER length check
Date: Mon, 24 Feb 2014 11:00:00 +0100
Message-ID: <1393236001-2445-13-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39127 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbaBXKAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:17 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This patch fixes commit d3623099d350 ("ipsec: add support of limited SA dump").

sadb_ext_min_len array should be updated with the new type (SADB_X_EXT_FILTER).

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index f0879c1..a50d979 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -365,6 +365,7 @@ static const u8 sadb_ext_min_len[] = {
 	[SADB_X_EXT_NAT_T_OA]		= (u8) sizeof(struct sadb_address),
 	[SADB_X_EXT_SEC_CTX]		= (u8) sizeof(struct sadb_x_sec_ctx),
 	[SADB_X_EXT_KMADDRESS]		= (u8) sizeof(struct sadb_x_kmaddress),
+	[SADB_X_EXT_FILTER]		= (u8) sizeof(struct sadb_x_filter),
 };
 
 /* Verify sadb_address_{len,prefixlen} against sa_family.  */
-- 
1.7.9.5
