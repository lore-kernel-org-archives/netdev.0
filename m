From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 9/11] r8169: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:28:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020142858.L8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        romieu@fr.zoreil.com
Content-Disposition: inline
In-Reply-To: <20041020141146.C8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:11:46PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to r8169 driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/r8169.c |    1 +
 1 files changed, 1 insertion(+)

--- linux-2.6.9/drivers/net/r8169.c.orig
+++ linux-2.6.9/drivers/net/r8169.c
@@ -362,6 +362,7 @@ MODULE_PARM(rx_copybreak, "i");
 MODULE_PARM(use_dac, "i");
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(RTL8169_VERSION);
 
 static int rtl8169_open(struct net_device *dev);
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
