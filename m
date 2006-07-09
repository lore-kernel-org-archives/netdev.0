From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Get rid of the last volatile.
Date: Sun, 9 Jul 2006 23:37:45 +0100
Message-ID: <20060709223745.GA20324@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:20444 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1161208AbWGIWk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 18:40:58 -0400
Received: from ftp.linux-mips.org (ftp.linux-mips.org [194.74.144.162])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k69Mei0S029441
	for <netdev@vger.kernel.org>; Sun, 9 Jul 2006 22:40:57 GMT
Received: from localhost.localdomain ([127.0.0.1]:23741 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133507AbWGIWhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 23:37:41 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This volatile makes no sense - not even wearing pink shades ...

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 4cf8754..e9d9429 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -102,8 +102,8 @@ static int ax25_rx_fragment(ax25_cb *ax2
 int ax25_rx_iframe(ax25_cb *ax25, struct sk_buff *skb)
 {
 	int (*func)(struct sk_buff *, ax25_cb *);
-	volatile int queued = 0;
 	unsigned char pid;
+	int queued = 0;
 
 	if (skb == NULL) return 0;
 
