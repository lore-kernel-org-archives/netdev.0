From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Rename "virtual ethernet device" to "virtual ethernet pair device".
Date: Wed, 7 Nov 2007 14:09:00 +1100
Message-ID: <200711071409.01000.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58622 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754874AbXKGDIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 22:08:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are already iSeries and pSeries virtual ethernet drivers called
veth; calling a local tunnel device "veth" is confusing.

I didn't rename the module nor the header, to avoid breaking
documentation and userspace programs respectively.  But I'd really
like to.  It'd also be nice to mention "containers" somewhere in the
help text (I'm assuming that's what it's for?).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5f800a6..033a847 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -135,11 +135,12 @@ config TUN
 
 	  If you don't know what to use this for, you don't need it.
 
-config VETH
-	tristate "Virtual ethernet device"
+config VETH_PAIR
+	tristate "Virtual ethernet pair device"
 	---help---
-	  The device is an ethernet tunnel. Devices are created in pairs. When
-	  one end receives the packet it appears on its pair and vice versa.
+	  This device is a local ethernet tunnel. Devices are created in pairs.
+	  When one end receives the packet it appears on its pair and vice
+	  versa.
 
 config NET_SB1000
 	tristate "General Instruments Surfboard 1000"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0e5fde4..20491b0 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -201,7 +201,7 @@ obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MACMACE) += macmace.o
 obj-$(CONFIG_MAC89x0) += mac89x0.o
 obj-$(CONFIG_TUN) += tun.o
-obj-$(CONFIG_VETH) += veth.o
+obj-$(CONFIG_VETH_PAIR) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
