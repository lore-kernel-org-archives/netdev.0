From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: [PATCH]: r8169: prototype parameter name consistency
Date: Sat, 05 Mar 2005 14:51:49 +0000
Message-ID: <4229C785.806@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040507070404080307080909"
Cc: Linux netdev <netdev@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040507070404080307080909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello.

Attached is a minor clean-up for consistency in the parameter names for 
a couple of prototypes in the r8169 driver.

Bye, Rich =]

Signed-Off-By: Richard Dawe <rich@phekda.gotadsl.co.uk>

--------------040507070404080307080909
Content-Type: text/plain;
 name="r8169-proto-consistency.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169-proto-consistency.patch"

--- linux-2.6.11/drivers/net/r8169.c.orig	2005-03-02 07:38:09.000000000 +0000
+++ linux-2.6.11/drivers/net/r8169.c	2005-03-05 14:41:29.000000000 +0000
@@ -433,10 +433,10 @@ static void rtl8169_hw_start(struct net_
 static int rtl8169_close(struct net_device *dev);
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
-static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
+static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
-static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 
 #ifdef CONFIG_R8169_NAPI

--------------040507070404080307080909--
