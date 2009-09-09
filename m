From: Joyce Yu <Joyce.Yu@sun.com>
Subject: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 14:10:48 -0700
Message-ID: <4AA819D8.1020306@Sun.COM>
Reply-To: Joyce.Yu@sun.com
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-4.Sun.COM ([192.18.98.36]:62099 "EHLO
	brmea-mail-4.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbZIIV1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 17:27:03 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n89LAs4M017046
	for <netdev@vger.kernel.org>; Wed, 9 Sep 2009 21:10:55 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KPQ00H002I1V000@mail-amer.sun.com> for netdev@vger.kernel.org; Wed,
 09 Sep 2009 15:10:54 -0600 (MDT)
Received: from [129.145.154.95] ([unknown] [129.145.154.95])
 by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 with ESMTPSA id <0KPQ007B12U0EU20@mail-amer.sun.com> for
 netdev@vger.kernel.org; Wed, 09 Sep 2009 15:10:49 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joyce Yu <joyce.yu@sun.com>
Date: Wed, 9 Sep 2009 08:43:00 -0700
Subject: [PATCH] VLAN does not work with niu driver
 Signed-off-by: Joyce Yu <joyce.yu@sun.com>

---
 drivers/net/niu.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index 3bd0b59..35678db 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2700,7 +2700,7 @@ struct fcram_hash_ipv6 {
 #define RCR_PKT_TYPE_UDP               0x2
 #define RCR_PKT_TYPE_SCTP              0x3

-#define NIU_RXPULL_MAX                 ETH_HLEN
+#define NIU_RXPULL_MAX                 64

 struct rx_pkt_hdr0 {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
--
1.6.4

-- 


