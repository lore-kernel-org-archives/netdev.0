From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Convert XFRM_MSG_* macros to an enum
Date: Sat, 3 Jul 2004 19:52:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040703095215.GA16195@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I'd like to add two new xfrm_user messages, FLUSHSA and FLUSHPOLICY.

I've cleaned up the existing MSG definitions by converting them to
an enum.  This should make future additions slightly easier in that
XFRM_MSG_MAX won't have to be touched again.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/xfrm.h 1.20 vs edited =====
--- 1.20/include/linux/xfrm.h	2004-05-30 05:35:21 +10:00
+++ edited/include/linux/xfrm.h	2004-07-03 19:43:11 +10:00
@@ -103,26 +103,28 @@
 };
 
 /* Netlink configuration messages.  */
-#define XFRM_MSG_BASE		0x10
+enum {
+	XFRM_MSG_BASE = 0x10,
 
-#define XFRM_MSG_NEWSA		(XFRM_MSG_BASE + 0)
-#define XFRM_MSG_DELSA		(XFRM_MSG_BASE + 1)
-#define XFRM_MSG_GETSA		(XFRM_MSG_BASE + 2)
+	XFRM_MSG_NEWSA = 0x10,
+	XFRM_MSG_DELSA,
+	XFRM_MSG_GETSA,
 
-#define XFRM_MSG_NEWPOLICY	(XFRM_MSG_BASE + 3)
-#define XFRM_MSG_DELPOLICY	(XFRM_MSG_BASE + 4)
-#define XFRM_MSG_GETPOLICY	(XFRM_MSG_BASE + 5)
+	XFRM_MSG_NEWPOLICY,
+	XFRM_MSG_DELPOLICY,
+	XFRM_MSG_GETPOLICY,
 
-#define XFRM_MSG_ALLOCSPI	(XFRM_MSG_BASE + 6)
-#define XFRM_MSG_ACQUIRE	(XFRM_MSG_BASE + 7)
-#define XFRM_MSG_EXPIRE		(XFRM_MSG_BASE + 8)
+	XFRM_MSG_ALLOCSPI,
+	XFRM_MSG_ACQUIRE,
+	XFRM_MSG_EXPIRE,
 
-#define XFRM_MSG_UPDPOLICY	(XFRM_MSG_BASE + 9)
-#define XFRM_MSG_UPDSA		(XFRM_MSG_BASE + 10)
+	XFRM_MSG_UPDPOLICY,
+	XFRM_MSG_UPDSA,
 
-#define XFRM_MSG_POLEXPIRE	(XFRM_MSG_BASE + 11)
+	XFRM_MSG_POLEXPIRE,
 
-#define XFRM_MSG_MAX		(XFRM_MSG_POLEXPIRE+1)
+	XFRM_MSG_MAX
+};
 
 struct xfrm_user_tmpl {
 	struct xfrm_id		id;

--y0ulUmNC+osPPQO6--
