From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for prism54usb
Date: Tue, 29 Aug 2006 18:13:45 -0700
Message-ID: <20060830011345.GP8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:53485 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932268AbWH3BOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 21:14:19 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

       Hi,

        WE-21 for Prism54 SoftMAC driver...
	Patch for wireless-2.6 git. And most likely useless ;-)

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/prism54usb/islsm_netdev.20.c linux/drivers/net/wireless/prism54usb/islsm_netdev.c
--- linux/drivers/net/wireless/prism54usb/islsm_netdev.20.c	2006-08-29 17:35:08.000000000 -0700
+++ linux/drivers/net/wireless/prism54usb/islsm_netdev.c	2006-08-29 17:36:59.000000000 -0700
@@ -1127,7 +1127,6 @@ alloc_islsm(int sizeof_priv)
 	netdev->tx_timeout = &islsm_tx_timeout;
 
 #ifdef MADWIFI
-	netdev->get_wireless_stats = &islsm_wireless_stats;
 	ieee80211_ioctl_iwsetup(&islsm_iw_handler_def);
 #endif				/* MADWIFI */
 	/* check if this can be done right away. Race ? */
diff -u -p linux/drivers/net/wireless/prism54usb/islsm_ioctl.20.c linux/drivers/net/wireless/prism54usb/islsm_ioctl.c
--- linux/drivers/net/wireless/prism54usb/islsm_ioctl.20.c	2006-08-29 17:35:16.000000000 -0700
+++ linux/drivers/net/wireless/prism54usb/islsm_ioctl.c	2006-08-29 17:36:46.000000000 -0700
@@ -604,6 +604,7 @@ struct iw_handler_def islsm_iw_handler_d
 	.num_standard = N(islsm_handlers),
 	.private = (iw_handler *) islsm_priv_handlers,
 	.num_private = N(islsm_priv_handlers),
+	.get_wireless_stats = islsm_wireless_stats,
 #undef N
 };
 
