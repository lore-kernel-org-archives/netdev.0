From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Store idev entries
Date: Wed, 4 May 2005 11:19:56 +1000
Message-ID: <20050504011956.GA20670@gondor.apana.org.au>
References: <4272EC95.20401@miyazawa.org> <20050430.120736.45974367.yoshfuji@linux-ipv6.org> <20050430031159.GA24326@gondor.apana.org.au> <20050430082339.GA20338@gondor.apana.org.au> <20050430114349.GA24573@gondor.apana.org.au> <20050503162628.7541807d.davem@davemloft.net> <42782025.3010700@trash.net> <20050504011204.GA19740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="mP3DRpeJDSE+ciuQ"
Cc: "David S. Miller" <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20050504011204.GA19740@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 04, 2005 at 11:12:04AM +1000, herbert wrote:
> On Wed, May 04, 2005 at 03:06:45AM +0200, Patrick McHardy wrote:
> > 
> > The patch causes a compile error here:
> > 
> >   CC      net/ipv6/xfrm6_policy.o
> > In file included from net/ipv6/xfrm6_policy.c:18:
> > include/net/addrconf.h:40: error: field `prefix' has incomplete type
> 
> Hmm, I wonder why I didn't see this.  Anyway, could you please add
> the include to addrconf.h instead?

Aha, I can see it if I do something like this.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--mP3DRpeJDSE+ciuQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/asm-i386/checksum.h 1.14 vs edited =====
--- 1.14/include/asm-i386/checksum.h	2005-01-16 22:58:42 +11:00
+++ edited/include/asm-i386/checksum.h	2005-05-04 11:17:09 +10:00
@@ -1,8 +1,6 @@
 #ifndef _I386_CHECKSUM_H
 #define _I386_CHECKSUM_H
 
-#include <linux/in6.h>
-
 /*
  * computes the checksum of a memory block at buff, length len,
  * and adds in "sum" (32-bit)
@@ -145,6 +143,7 @@
 }
 
 #define _HAVE_ARCH_IPV6_CSUM
+struct in6_addr;
 static __inline__ unsigned short int csum_ipv6_magic(struct in6_addr *saddr,
 						     struct in6_addr *daddr,
 						     __u32 len,

--mP3DRpeJDSE+ciuQ--
