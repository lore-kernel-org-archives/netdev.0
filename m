From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETLINK] Kill export of netlink_broadcast_deliver
Date: Tue, 28 Sep 2004 13:47:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928034736.GA10589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

netlink_broadcast_deliver is marked as static as well as exported.
It certainly isn't doing anything that should be needed by any
netlink modules.  There aren't any in-kernel users either.

So let's remove the bogus export.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/netlink/af_netlink.c 1.53 vs edited =====
--- 1.53/net/netlink/af_netlink.c	2004-09-22 12:32:44 +10:00
+++ edited/net/netlink/af_netlink.c	2004-09-28 13:45:28 +10:00
@@ -1220,7 +1220,6 @@
 
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_broadcast);
-EXPORT_SYMBOL(netlink_broadcast_deliver);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
 EXPORT_SYMBOL(netlink_register_notifier);

--4Ckj6UjgE2iN1+kY--
