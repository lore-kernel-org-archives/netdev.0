From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] r8169: clean up my printk uglyness
Date: Thu, 1 Apr 2010 13:30:07 -0400
Message-ID: <20100401173007.GC14069@shamino.rdu.redhat.com>
References: <20100401145356.GB14069@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, brandon@ifup.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33860 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755478Ab0DARbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 13:31:32 -0400
Content-Disposition: inline
In-Reply-To: <20100401145356.GB14069@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 10:53:56AM -0400, Neil Horman wrote:
> Fix formatting on r8169 printk
> 
> Brandon Philips noted that I had a spacing issue in my printk for the last r8169
> patch that made it quite ugly.  Fix that up and add the PFX macro to it as well
> so it looks like the other r8169 printks
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
Grr, yes thanks, V2, fixing my idiocy :)

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
+			"NIC may lead to frame reception errors!\n");
 
 	tp->rx_buf_sz = (max_frame > RX_BUF_SIZE) ? max_frame : RX_BUF_SIZE;
 }

