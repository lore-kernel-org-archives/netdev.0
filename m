From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 7/12] Host AP: Fix compilation with PRISM2_NO_STATION_MODES defined.
Date: Sun, 7 Nov 2004 23:14:27 -0800
Message-ID: <20041108071427.GH1076@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-07 22:38:44 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-07 22:38:44 -08:00
@@ -597,6 +597,7 @@
 }
 
 
+#ifndef PRISM2_NO_STATION_MODES
 static int hostap_join_ap(struct net_device *dev)
 {
 	struct hostap_interface *iface = dev->priv;
@@ -634,6 +635,7 @@
 
 	return 0;
 }
+#endif /* PRISM2_NO_STATION_MODES */
 
 
 static int prism2_ioctl_siwap(struct net_device *dev,
@@ -1586,7 +1588,8 @@
 
 #else /* !PRISM2_NO_STATION_MODES */
 
-static inline int prism2_request_hostscan(struct net_device *dev)
+static inline int prism2_request_hostscan(struct net_device *dev,
+					  u8 *ssid, u8 ssid_len)
 {
 	return -EOPNOTSUPP;
 }


-- 
Jouni Malinen                                            PGP id EFC895FA
