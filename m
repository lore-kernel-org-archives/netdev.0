From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] Include ipv6.h for ipv6_addr_set
Date: Sat, 30 Apr 2005 17:38:45 +1000
Message-ID: <20050430073845.GA3515@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch includes net/ipv6.h from addrconf.h since it needs
ipv6_addr_set.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=ipv6-1

--- k/include/net/addrconf.h  (mode:100644)
+++ l/include/net/addrconf.h  (mode:100644)
@@ -46,6 +46,7 @@ struct prefix_info {
 #include <linux/in6.h>
 #include <linux/netdevice.h>
 #include <net/if_inet6.h>
+#include <net/ipv6.h>
 
 #define IN6_ADDR_HSIZE		16
 

--AqsLC8rIMeq19msA--
