From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] NS83820: Handle multicast frames.
Date: Tue, 17 Jul 2007 13:45:54 +0900 (JST)
Message-ID: <20070717.134554.126619013.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:48115 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbXGQEpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 00:45:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 104aab3..ea80e6c 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1582,7 +1582,7 @@ static void ns83820_set_multicast(struct net_device *ndev)
 	else
 		and_mask &= ~(RFCR_AAU | RFCR_AAM);
 
-	if (ndev->flags & IFF_ALLMULTI)
+	if (ndev->flags & IFF_ALLMULTI || ndev->mc_count)
 		or_mask |= RFCR_AAM;
 	else
 		and_mask &= ~RFCR_AAM;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
