From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: hamradio/baycom and "make allyesconfig"
Date: Sat, 27 Sep 2003 20:58:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030927205845.64c26951.shemminger@osdl.org>
References: <20030926164821.1e83dce9.shemminger@osdl.org>
	<3F76458C.7030600@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F76458C.7030600@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry, overlooked the corresponding .h file in that patch, here it is.

diff -Nru a/include/linux/hdlcdrv.h b/include/linux/hdlcdrv.h
--- a/include/linux/hdlcdrv.h	Sat Sep 27 20:57:18 2003
+++ b/include/linux/hdlcdrv.h	Sat Sep 27 20:57:18 2003
@@ -359,11 +359,11 @@
 void hdlcdrv_receiver(struct net_device *, struct hdlcdrv_state *);
 void hdlcdrv_transmitter(struct net_device *, struct hdlcdrv_state *);
 void hdlcdrv_arbitrate(struct net_device *, struct hdlcdrv_state *);
-int hdlcdrv_register_hdlcdrv(struct net_device *dev, const struct hdlcdrv_ops *ops,
-			     unsigned int privsize, char *ifname,
-			     unsigned int baseaddr, unsigned int irq, 
-			     unsigned int dma);
-int hdlcdrv_unregister_hdlcdrv(struct net_device *dev);
+struct net_device *hdlcdrv_register(const struct hdlcdrv_ops *ops,
+				    unsigned int privsize, const char *ifname,
+				    unsigned int baseaddr, unsigned int irq, 
+				    unsigned int dma);
+void hdlcdrv_unregister(struct net_device *dev);
 
 /* -------------------------------------------------------------------- */
 
