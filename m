From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH] Include asm/atomic.h for atomic_t
Date: Thu, 15 Jan 2004 19:00:50 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115080050.GA8430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

include/net/flow.h uses atomic_t without including asm/atomic.h which
sometimes causes build failures.  This patch adds the inclusion.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-2.5/include/net/flow.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/flow.h,v
retrieving revision 1.3
diff -u -r1.3 flow.h
--- kernel-2.5/include/net/flow.h	13 Jun 2003 11:22:07 -0000	1.3
+++ kernel-2.5/include/net/flow.h	15 Jan 2004 07:58:21 -0000
@@ -8,6 +8,7 @@
 #define _NET_FLOW_H
 
 #include <linux/in6.h>
+#include <asm/atomic.h>
 
 struct flowi {
 	int	oif;

--bg08WKrSYDhXBjb5--
