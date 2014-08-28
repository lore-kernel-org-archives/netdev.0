From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 1/9] net: Allocate a new 16 bits for flags in
 skbuff
Date: Wed, 27 Aug 2014 21:48:48 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272147220.550@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:36497 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932473AbaH1FDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 01:03:24 -0400
Received: by mail-yk0-f201.google.com with SMTP id 142so148012ykq.2
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 22:03:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b69b7b5..3c9574c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -598,6 +598,10 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
+	kmemcheck_bitfield_begin(flags3);
+	/* 16 bit hole */
+	kmemcheck_bitfield_end(flags3);
+
 	__be16			inner_protocol;
 	__u16			inner_transport_header;
 	__u16			inner_network_header;
-- 
2.1.0.rc2.206.gedb03e5
