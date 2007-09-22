From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH -mm] iseries_veth: Kill unused variable
Date: Sat, 22 Sep 2007 13:25:47 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709221324430.22517@enigma.security.iitk.ac.in>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47468 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbXIVHwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 03:52:49 -0400
In-Reply-To: <20070918011841.2381bd93.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


drivers/net/iseries_veth.c: In function 'veth_transmit_to_many':
drivers/net/iseries_veth.c:1174: warning: unused variable 'port'

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/net/iseries_veth.c |    1 -
 1 file changed, 1 deletion(-)

diff -ruNp a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
--- a/drivers/net/iseries_veth.c	2007-09-22 06:26:39.000000000 +0530
+++ b/drivers/net/iseries_veth.c	2007-09-22 11:17:29.000000000 +0530
@@ -1171,7 +1171,6 @@ static void veth_transmit_to_many(struct
 					  HvLpIndexMap lpmask,
 					  struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
 	int i, success, error;
 
 	success = error = 0;
