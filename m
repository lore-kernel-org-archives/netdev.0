From: Joe Perches <joe@perches.com>
Subject: [PATCH] 2.6.0-test5-bk11 PKT_CAN_SHARE_SKB [1/3]
	include/linux/netdevice.h
Date: Wed, 24 Sep 2003 15:33:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064442780.15437.25.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
	 <1064423867.15283.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David S Miller <davem@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <1064423867.15283.11.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-09-24 at 10:17, Joe Perches wrote: 
> On Wed, 2003-09-24 at 10:13, Linus Torvalds wrote:
> > Looks sane, but wouldn't it be cleaner to put this ugly special case logic
> > with casts etc in an inline function and make the code a bit more readable
> > at the same time?
> 
> I've got those.
> 
> I've done the ((void*)1) conversions to PKT_SHARED_SKBs
> and found this missing.  I'll submit those separately.
diff -urN linux-2.6.0-test5/include/linux/netdevice.h shared_skb/include/linux/netdevice.h
-- linux-2.6.0-test5/include/linux/netdevice.h	2003-09-22 08:04:03.000000000 -0700
+++ shared_skb/include/linux/netdevice.h	2003-09-22 13:10:07.000000000 -0700
@@ -477,6 +477,7 @@
  */
 #define SET_NETDEV_DEV(net, pdev)	((net)->class_dev.dev = (pdev))
 
+#define PKT_CAN_SHARE_SKB	((void*)1)
 
 struct packet_type 
 {
