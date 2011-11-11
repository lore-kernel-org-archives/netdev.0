From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [ver3 PATCH 1/6] virtio_net: Introduce VIRTIO_NET_F_MULTIQUEUE
Date: Fri, 11 Nov 2011 18:32:51 +0530
Message-ID: <20111111130251.9878.41799.sendpatchset@krkumar2.in.ibm.com>
References: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	davem@davemloft.net, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111111130223.9878.59517.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce VIRTIO_NET_F_MULTIQUEUE. 

Signed-off-by: krkumar2@in.ibm.com
---
 include/linux/virtio_net.h |    1 +
 1 file changed, 1 insertion(+)

diff -ruNp org/include/linux/virtio_net.h new/include/linux/virtio_net.h
--- org/include/linux/virtio_net.h	2011-10-12 10:16:46.000000000 +0530
+++ new/include/linux/virtio_net.h	2011-11-11 16:44:34.000000000 +0530
@@ -49,6 +49,7 @@
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
+#define VIRTIO_NET_F_MULTIQUEUE	21	/* Device supports multiple TXQ/RXQ */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 

