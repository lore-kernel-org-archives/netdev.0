From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Sat, 3 Jul 2004 20:10:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703101058.GA18173@gondor.apana.org.au>
References: <20040703095215.GA16195@gondor.apana.org.au> <20040703.190042.70899669.yoshfuji@linux-ipv6.org> <20040703100208.GA16339@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040703100208.GA16339@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jul 03, 2004 at 08:02:08PM +1000, herbert wrote:
> 
> I think such applications are broken.
> 
> They should compile with headers that define these symbols and
> test for their support at run-time.
> 
> Applications should not detect kernel features at compile-time.

Well, I guess there are always going to be broken applications.
I'd move on rather than dwell on this point.

So here is an add-on patch to add the macros.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/xfrm.h 1.21 vs edited =====
--- 1.21/include/linux/xfrm.h	2004-07-03 19:53:19 +10:00
+++ edited/include/linux/xfrm.h	2004-07-03 20:07:15 +10:00
@@ -107,21 +107,33 @@
 	XFRM_MSG_BASE = 0x10,
 
 	XFRM_MSG_NEWSA = 0x10,
+#define XFRM_MSG_NEWSA XFRM_MSG_NEWSA
 	XFRM_MSG_DELSA,
+#define XFRM_MSG_DELSA XFRM_MSG_DELSA
 	XFRM_MSG_GETSA,
+#define XFRM_MSG_GETSA XFRM_MSG_GETSA
 
 	XFRM_MSG_NEWPOLICY,
+#define XFRM_MSG_NEWPOLICY XFRM_MSG_NEWPOLICY
 	XFRM_MSG_DELPOLICY,
+#define XFRM_MSG_DELPOLICY XFRM_MSG_DELPOLICY
 	XFRM_MSG_GETPOLICY,
+#define XFRM_MSG_GETPOLICY XFRM_MSG_GETPOLICY
 
 	XFRM_MSG_ALLOCSPI,
+#define XFRM_MSG_ALLOCSPI XFRM_MSG_ALLOCSPI
 	XFRM_MSG_ACQUIRE,
+#define XFRM_MSG_ACQUIRE XFRM_MSG_ACQUIRE
 	XFRM_MSG_EXPIRE,
+#define XFRM_MSG_EXPIRE XFRM_MSG_EXPIRE
 
 	XFRM_MSG_UPDPOLICY,
+#define XFRM_MSG_UPDPOLICY XFRM_MSG_UPDPOLICY
 	XFRM_MSG_UPDSA,
+#define XFRM_MSG_UPDSA XFRM_MSG_UPDSA
 
 	XFRM_MSG_POLEXPIRE,
+#define XFRM_MSG_POLEXPIRE XFRM_MSG_POLEXPIRE
 
 	XFRM_MSG_MAX
 };

--GvXjxJ+pjyke8COw--
