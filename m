From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 1/3] net: Introduce skb_checksum_start_offset()
Date: Wed, 15 Dec 2010 02:24:08 +0100 (CET)
Message-ID: <b1d596064d2b9ae518f79ac82711ff84ea46a19d.1292372504.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59362 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757646Ab0LOBYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 20:24:11 -0500
In-Reply-To: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce skb_checksum_start_offset() to replace repetitive calculation=
=2E

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/skbuff.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19f37a6..0491da5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1355,6 +1355,11 @@ static inline void skb_set_mac_header(struct sk_=
buff *skb, const int offset)
 }
 #endif /* NET_SKBUFF_DATA_USES_OFFSET */
=20
+static inline int skb_checksum_start_offset(const struct sk_buff *skb)
+{
+	return skb->csum_start - skb_headroom(skb);
+}
+
 static inline int skb_transport_offset(const struct sk_buff *skb)
 {
 	return skb_transport_header(skb) - skb->data;
--=20
1.7.2.3

