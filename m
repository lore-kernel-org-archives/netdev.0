From: Rolf Eike Beer <eb@emlix.com>
Subject: [PATCH] netlink: correctly document nla_put_u64_64bit()
Date: Thu, 13 Jul 2017 16:50:24 +0200
Message-ID: <15468457.IYSIRIbmYT@devpool21>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([46.4.235.150]:40676 "EHLO mx1.emlix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751201AbdGMO6p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 10:58:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 90bda8d1bc2a0c5d283e4e0a4b19812a4cce72bd Mon Sep 17 00:00:00 2001
From: Rolf Eike Beer <eb@emlix.com>
Date: Thu, 13 Jul 2017 16:46:43 +0200
Subject: [PATCH] netlink: correctly document nla_put_u64_64bit()

Signed-off-by: Rolf Eike Beer <eb@emlix.com>
---
 include/net/netlink.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 01709172b3d3..ef8e6c3a80a6 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -98,8 +98,8 @@
  *   nla_put_u8(skb, type, value)	add u8 attribute to skb
  *   nla_put_u16(skb, type, value)	add u16 attribute to skb
  *   nla_put_u32(skb, type, value)	add u32 attribute to skb
- *   nla_put_u64_64bits(skb, type,
- *			value, padattr)	add u64 attribute to skb
+ *   nla_put_u64_64bit(skb, type,
+ *                     value, padattr)	add u64 attribute to skb
  *   nla_put_s8(skb, type, value)	add s8 attribute to skb
  *   nla_put_s16(skb, type, value)	add s16 attribute to skb
  *   nla_put_s32(skb, type, value)	add s32 attribute to skb
-- 
2.13.2


-- 
Rolf Eike Beer, emlix GmbH, http://www.emlix.com
Fon +49 551 30664-0, Fax +49 551 30664-11
Bertha-von-Suttner-Str. 9, 37085 Göttingen, Germany
Sitz der Gesellschaft: Göttingen, Amtsgericht Göttingen HR B 3160
Geschäftsführung: Heike Jordan, Dr. Uwe Kracke – Ust-IdNr.: DE 205 198 055

emlix – smart embedded open source
