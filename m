From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 20/24] RT2x00: Use SET_NETDEV_DEV
Date: Wed, 26 Jul 2006 19:05:47 +0200
Message-ID: <200607261905.47706.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030308AbWGZRHr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:47 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:47 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Use SET_NETDEV_DEV to help userspace detect the wireless interfaces.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 10:41:21.000000000 +0200
+++ wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 10:46:52.000000000 +0200
@@ -2795,6 +2795,7 @@
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2400pci_ethtool_ops);
+	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	pci_set_drvdata(pci_dev, net_dev);
 
diff -rU3 wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 10:41:32.000000000 +0200
+++ wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 10:46:48.000000000 +0200
@@ -3066,6 +3066,7 @@
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2500pci_ethtool_ops);
+	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	pci_set_drvdata(pci_dev, net_dev);
 
diff -rU3 wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 10:42:02.000000000 +0200
+++ wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 10:46:32.000000000 +0200
@@ -2686,6 +2686,7 @@
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2500usb_ethtool_ops);
+	SET_NETDEV_DEV(net_dev, &usb_intf->dev);
 
 	usb_set_intfdata(usb_intf, net_dev);
 
diff -rU3 wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 
10:41:48.000000000 +0200
+++ wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-26 10:46:44.000000000 +0200
@@ -3634,6 +3634,7 @@
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt61pci_ethtool_ops);
+	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
 
 	pci_set_drvdata(pci_dev, net_dev);
 
diff -rU3 wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-reset/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 
10:42:19.000000000 +0200
+++ wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-26 10:46:22.000000000 +0200
@@ -3081,6 +3081,7 @@
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt73usb_ethtool_ops);
+	SET_NETDEV_DEV(net_dev, &usb_intf->dev);
 
 	usb_set_intfdata(usb_intf, net_dev);
 
