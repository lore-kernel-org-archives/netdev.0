From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 3/2] forcedeth: Compile fix forcedeth 0.44
Date: Sun, 18 Sep 2005 16:18:05 +0200
Message-ID: <432D771D.7050107@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040706090009010407050300"
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040706090009010407050300
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

forcedeth-0.44 contains a spurious ; in nv_release_txskb. gcc-4 compiles 
it with a warning, older compilers might reject it.
The attached onliner fixes that, sorry.

Signed-off-By: Manfred Spraul <manfred@colorfullife.com>

--------------040706090009010407050300
Content-Type: text/plain;
 name="patch-forcedeth-044a-compilefix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-044a-compilefix"

--- 2.6/drivers/net/forcedeth.c	2005-09-18 16:12:10.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-09-18 16:14:19.000000000 +0200
@@ -923,7 +923,7 @@ static int nv_init_ring(struct net_devic
 static void nv_release_txskb(struct net_device *dev, unsigned int skbnr)
 {
 	struct fe_priv *np = get_nvpriv(dev);
-	struct sk_buff *skb = np->tx_skbuff[skbnr];;
+	struct sk_buff *skb = np->tx_skbuff[skbnr];
 	unsigned int j, entry, fragments;
 			
 	dprintk(KERN_INFO "%s: nv_release_txskb for skbnr %d, skb %p\n",

--------------040706090009010407050300--
