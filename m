From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] r8169: clean up my printk uglyness
Date: Thu, 1 Apr 2010 10:53:56 -0400
Message-ID: <20100401145356.GB14069@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, nhorman@tuxdriver.com,
	brandon@ifup.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33933 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185Ab0DAOzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 10:55:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix formatting on r8169 printk

Brandon Philips noted that I had a spacing issue in my printk for the last r8169
patch that made it quite ugly.  Fix that up and add the PFX macro to it as well
so it looks like the other r8169 printks

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 r8169.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9674005..a119885 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3227,8 +3227,8 @@ static void rtl8169_set_rxbufsize(struct rtl8169_private *tp,
 	unsigned int max_frame = mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
 
 	if (max_frame != 16383)
-		printk(KERN_WARNING "WARNING! Changing of MTU on this NIC"
-			"May lead to frame reception errors!\n");
+		printk(KERN_WARNING PFX "WARNING! Changing of MTU on this "
+			"NIC May lead to frame reception errors!\n");
 
 	tp->rx_buf_sz = (max_frame > RX_BUF_SIZE) ? max_frame : RX_BUF_SIZE;
 }
