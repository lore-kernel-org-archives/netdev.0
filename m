From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPSEC] Store idev entries
Date: Wed, 04 May 2005 03:06:45 +0200
Message-ID: <42782025.3010700@trash.net>
References: <4272EC95.20401@miyazawa.org>	<20050430.120736.45974367.yoshfuji@linux-ipv6.org>	<20050430031159.GA24326@gondor.apana.org.au>	<20050430082339.GA20338@gondor.apana.org.au>	<20050430114349.GA24573@gondor.apana.org.au> <20050503162628.7541807d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010304080206040500020904"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503162628.7541807d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010304080206040500020904
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David S. Miller wrote:
> On Sat, 30 Apr 2005 21:43:49 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>>The ref counting on loopback_idev wasn't quite right.  Here is the
>>corrected version.
> 
> 
> Applied, thanks Herbert.

The patch causes a compile error here:

  CC      net/ipv6/xfrm6_policy.o
In file included from net/ipv6/xfrm6_policy.c:18:
include/net/addrconf.h:40: error: field `prefix' has incomplete type

This patch fixes it.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------010304080206040500020904
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

Index: net/ipv6/xfrm6_policy.c
===================================================================
--- 591ce19741741438606ab75a45ac9f973cbb4787/net/ipv6/xfrm6_policy.c  (mode:100644 sha1:4429b1a1fe5fe2528318b7417e539279548d9988)
+++ uncommitted/net/ipv6/xfrm6_policy.c  (mode:100644)
@@ -15,6 +15,7 @@
 #include <linux/compiler.h>
 #include <linux/config.h>
 #include <linux/netdevice.h>
+#include <linux/in6.h>
 #include <net/addrconf.h>
 #include <net/xfrm.h>
 #include <net/ip.h>

--------------010304080206040500020904--
