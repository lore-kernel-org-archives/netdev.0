From: akpm@linux-foundation.org
Subject: [patch 1/4] pfkey: sending an SADB_GET responds with an SADB_GET
Date: Wed, 21 Nov 2007 15:02:13 -0800
Message-ID: <200711212302.lALN2DYa013601@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	chardin@2wire.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33679 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754087AbXKUXCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:02:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Charles Hardin <chardin@2wire.com>

Kernel needs to respond to an SADB_GET with the same message type to
conform to the RFC 2367 Section 3.1.5

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/key/af_key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/key/af_key.c~pfkey-sending-an-sadb_get-responds-with-an-sadb_get net/key/af_key.c
--- a/net/key/af_key.c~pfkey-sending-an-sadb_get-responds-with-an-sadb_get
+++ a/net/key/af_key.c
@@ -1552,7 +1552,7 @@ static int pfkey_get(struct sock *sk, st
 
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = hdr->sadb_msg_version;
-	out_hdr->sadb_msg_type = SADB_DUMP;
+	out_hdr->sadb_msg_type = SADB_GET;
 	out_hdr->sadb_msg_satype = pfkey_proto2satype(proto);
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_reserved = 0;
_
