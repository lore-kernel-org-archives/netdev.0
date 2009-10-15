From: Joyce Yu <Joyce.Yu@Sun.COM>
Subject: [PATCH] [NIU] VLAN does not work with niu driver
Date: Thu, 15 Oct 2009 12:16:48 -0700
Message-ID: <4AD77520.4050406@Sun.COM>
Reply-To: Joyce.Yu@Sun.COM
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_NBpdxnECRUioYr+BFnBkFw)"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brmea-mail-4.Sun.COM ([192.18.98.36]:61663 "EHLO
	brmea-mail-4.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762958AbZJOTRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 15:17:40 -0400
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n9FJGwUs028448
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 19:16:59 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KRK00B00IKZYG00@mail-amer.sun.com> for netdev@vger.kernel.org; Thu,
 15 Oct 2009 13:16:58 -0600 (MDT)
Received: from [129.145.154.82] ([unknown] [129.145.154.82])
 by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 with ESMTPSA id <0KRK008H5LK06K40@mail-amer.sun.com> for
 netdev@vger.kernel.org; Thu, 15 Oct 2009 13:16:49 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--Boundary_(ID_NBpdxnECRUioYr+BFnBkFw)
Content-type: text/plain; CHARSET=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT


-- 


--Boundary_(ID_NBpdxnECRUioYr+BFnBkFw)
Content-type: text/x-patch; name=0001-VLAN-does-not-work-with-niu-driver.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline;
 filename=0001-VLAN-does-not-work-with-niu-driver.patch

>From eb878a6887fed77e6b4c69a014a2c98ea2b52736 Mon Sep 17 00:00:00 2001
From: Joyce Yu <joyce.yu@sun.com>
Date: Thu, 15 Oct 2009 06:49:29 -0700
Subject: [PATCH] VLAN does not work with niu driver

---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index f9364d0..d6c7ac6 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3545,7 +3545,7 @@ static int niu_process_rx_pkt(struct napi_struct *napi, struct niu *np,
 	rp->rcr_index = index;
 
 	skb_reserve(skb, NET_IP_ALIGN);
-	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));
+	__pskb_pull_tail(skb, min(len, VLAN_ETH_HLEN));
 
 	rp->rx_packets++;
 	rp->rx_bytes += skb->len;
-- 
1.6.4


--Boundary_(ID_NBpdxnECRUioYr+BFnBkFw)--
