From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 19 Sep 2004 20:39:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095640781.1047.168.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-3cWj/G40spLwEklC0FOz"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040918203319.24004d6e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-3cWj/G40spLwEklC0FOz
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2004-09-18 at 23:33, David S. Miller wrote:
> So, before we even think about trying new faster algorithms
> in net/ipv4/fib_hash.c we have to clean it up.

Will look at rest of patch and get back to you. Curious piece like you
note:


> Does anyone know what this test:
> 
> 		if (!iter->zone->fz_next)
> 			continue;
> 
> in fib_get_first() is doing?  I kept it there
> but it looks fishy.  

Yes, it is fishy;-> patch attached. Probably one of the more interesting
typos i have seen recently

cheers,
jamal




--=-3cWj/G40spLwEklC0FOz
Content-Disposition: attachment; filename=fibhash_p
Content-Type: text/plain; name=fibhash_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/ipv4/fib_hash.c	2004/09/20 00:35:16	1.1
+++ b/net/ipv4/fib_hash.c	2004/09/20 00:36:16
@@ -915,7 +915,7 @@
 	     iter->zone = iter->zone->fz_next) {
 		int maxslot;
 
-		if (!iter->zone->fz_next)
+		if (!iter->zone->fz_nent)
 			continue;
 
 		iter->hash = iter->zone->fz_hash;

--=-3cWj/G40spLwEklC0FOz--
