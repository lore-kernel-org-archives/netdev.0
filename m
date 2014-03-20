From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net] netlink: fix setsockopt in mmap examples in
 documentation
Date: Wed, 19 Mar 2014 21:54:20 -0700
Message-ID: <20140319215420.49a6408d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35462 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750963AbaCTFUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 01:20:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documentation for how to use netlink mmap interface is incorrect.
The calls to setsockopt() require an additional argument.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/Documentation/networking/netlink_mmap.txt	2013-11-21 17:22:02.719654412 -0800
+++ b/Documentation/networking/netlink_mmap.txt	2014-03-19 21:13:51.994890229 -0700
@@ -226,9 +226,9 @@ Ring setup:
 	void *rx_ring, *tx_ring;
 
 	/* Configure ring parameters */
-	if (setsockopt(fd, NETLINK_RX_RING, &req, sizeof(req)) < 0)
+	if (setsockopt(fd, SOL_NETLINK, NETLINK_RX_RING, &req, sizeof(req)) < 0)
 		exit(1);
-	if (setsockopt(fd, NETLINK_TX_RING, &req, sizeof(req)) < 0)
+	if (setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, &req, sizeof(req)) < 0)
 		exit(1)
 
 	/* Calculate size of each individual ring */
