From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Wed, 22 Sep 2004 12:07:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922020729.GA14062@gondor.apana.org.au>
References: <20040918203319.24004d6e.davem@davemloft.net> <1095645106.1048.190.camel@jzny.localdomain> <20040919195351.0b3560e6.davem@davemloft.net> <1095686672.1049.301.camel@jzny.localdomain> <20040920121123.70baf895.davem@davemloft.net> <20040921034212.GA28462@gondor.apana.org.au> <20040920231805.3f18479c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040920231805.3f18479c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 20, 2004 at 11:18:05PM -0700, David S. Miller wrote:
>
> > Yes CONFIG_IP_ROUTE_TOS has out-lived its usefulness.  It has
> > always seemed half-hearted compared to CONFIG_IP_ROUTE_FWMARK.
> 
> Ok, then I'm gonna nuke it.

Here is a follow-up patch to get rid of the remaining Kconfig references.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/Kconfig 1.18 vs edited =====
--- 1.18/net/ipv4/Kconfig	2004-09-22 06:35:25 +10:00
+++ edited/net/ipv4/Kconfig	2004-09-22 11:47:08 +10:00
@@ -60,12 +60,8 @@
 	  Normally, a router decides what to do with a received packet based
 	  solely on the packet's final destination address. If you say Y here,
 	  the Linux router will also be able to take the packet's source
-	  address into account. Furthermore, if you also say Y to "Use TOS
-	  value as routing key" below, the TOS (Type-Of-Service) field of the
-	  packet can be used for routing decisions as well. In addition, if
-	  you say Y here and to "Fast network address translation" below,
-	  the router will also be able to modify source and destination
-	  addresses of forwarded packets.
+	  address into account. Furthermore, the TOS (Type-Of-Service) field
+	  of the packet can be used for routing decisions as well.
 
 	  If you are interested in this, please see the preliminary
 	  documentation at <http://www.compendium.com.ar/policy-routing.txt>

--MGYHOYXEY6WxJCY8--
