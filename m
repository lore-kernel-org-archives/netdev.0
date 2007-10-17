From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Fix return type for snmp6_free_dev()
Date: Wed, 17 Oct 2007 14:29:11 +0400
Message-ID: <4715E3F7.7050506@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59919 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117AbXJQKdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 06:33:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This call is essentially void.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 52d10d2..edf06ca 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -283,12 +283,11 @@ err_ip:
 	return err;
 }
 
-static int snmp6_free_dev(struct inet6_dev *idev)
+static void snmp6_free_dev(struct inet6_dev *idev)
 {
 	snmp_mib_free((void **)idev->stats.icmpv6msg);
 	snmp_mib_free((void **)idev->stats.icmpv6);
 	snmp_mib_free((void **)idev->stats.ipv6);
-	return 0;
 }
 
 /* Nobody refers to this device, we may destroy it. */
