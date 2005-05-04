From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC] Store idev entries
Date: Wed, 04 May 2005 03:20:11 +0200
Message-ID: <4278234B.2080605@trash.net>
References: <4272EC95.20401@miyazawa.org> <20050430.120736.45974367.yoshfuji@linux-ipv6.org> <20050430031159.GA24326@gondor.apana.org.au> <20050430082339.GA20338@gondor.apana.org.au> <20050430114349.GA24573@gondor.apana.org.au> <20050503162628.7541807d.davem@davemloft.net> <42782025.3010700@trash.net> <20050504011204.GA19740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090201060903000203060606"
Cc: "David S. Miller" <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050504011204.GA19740@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090201060903000203060606
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Hmm, I wonder why I didn't see this.  Anyway, could you please add
> the include to addrconf.h instead?

Sure, I missed the includes below and thought users of the file were
supposed to include it first.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------090201060903000203060606
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

Index: include/net/addrconf.h
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/include/net/addrconf.h  (mode:100644 sha1:f1e5af4be98e4a9cde314a5c1ceeaf3a61cf87ad)
+++ uncommitted/include/net/addrconf.h  (mode:100644)
@@ -17,6 +17,8 @@
 
 #define IPV6_MAX_ADDRESSES		16
 
+#include <linux/in6.h>
+
 struct prefix_info {
 	__u8			type;
 	__u8			length;
@@ -43,7 +45,6 @@
 
 #ifdef __KERNEL__
 
-#include <linux/in6.h>
 #include <linux/netdevice.h>
 #include <net/if_inet6.h>
 #include <net/ipv6.h>

--------------090201060903000203060606--
