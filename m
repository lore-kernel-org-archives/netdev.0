From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RTNETLINK] Convert RTM_* to enum
Date: Wed, 15 Sep 2004 12:09:42 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915020942.GA32721@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I decided to bite the bullet and use netlink for the tunnel operations.
Before I do that, here is a patch to convert the RTM_* constants to an
enum.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/rtnetlink.h 1.43 vs edited =====
--- 1.43/include/linux/rtnetlink.h	2004-09-10 03:24:53 +10:00
+++ edited/include/linux/rtnetlink.h	2004-09-15 11:45:24 +10:00
@@ -9,53 +9,89 @@
 
 /* Types of messages */
 
-#define RTM_BASE	0x10
-
-#define	RTM_NEWLINK	(RTM_BASE+0)
-#define	RTM_DELLINK	(RTM_BASE+1)
-#define	RTM_GETLINK	(RTM_BASE+2)
-#define	RTM_SETLINK	(RTM_BASE+3)
-
-#define	RTM_NEWADDR	(RTM_BASE+4)
-#define	RTM_DELADDR	(RTM_BASE+5)
-#define	RTM_GETADDR	(RTM_BASE+6)
-
-#define	RTM_NEWROUTE	(RTM_BASE+8)
-#define	RTM_DELROUTE	(RTM_BASE+9)
-#define	RTM_GETROUTE	(RTM_BASE+10)
-
-#define	RTM_NEWNEIGH	(RTM_BASE+12)
-#define	RTM_DELNEIGH	(RTM_BASE+13)
-#define	RTM_GETNEIGH	(RTM_BASE+14)
-
-#define	RTM_NEWRULE	(RTM_BASE+16)
-#define	RTM_DELRULE	(RTM_BASE+17)
-#define	RTM_GETRULE	(RTM_BASE+18)
-
-#define	RTM_NEWQDISC	(RTM_BASE+20)
-#define	RTM_DELQDISC	(RTM_BASE+21)
-#define	RTM_GETQDISC	(RTM_BASE+22)
-
-#define	RTM_NEWTCLASS	(RTM_BASE+24)
-#define	RTM_DELTCLASS	(RTM_BASE+25)
-#define	RTM_GETTCLASS	(RTM_BASE+26)
-
-#define	RTM_NEWTFILTER	(RTM_BASE+28)
-#define	RTM_DELTFILTER	(RTM_BASE+29)
-#define	RTM_GETTFILTER	(RTM_BASE+30)
-
-#define RTM_NEWACTION   (RTM_BASE+32)
-#define RTM_DELACTION   (RTM_BASE+33)
-#define RTM_GETACTION   (RTM_BASE+34)
-
-#define RTM_NEWPREFIX	(RTM_BASE+36)
-#define RTM_GETPREFIX	(RTM_BASE+38)
-
-#define	RTM_GETMULTICAST (RTM_BASE+42)
-
-#define	RTM_GETANYCAST	(RTM_BASE+46)
-
-#define	RTM_MAX		(RTM_BASE+47)
+enum {
+	RTM_BASE	= 16,
+#define RTM_BASE	RTM_BASE
+
+	RTM_NEWLINK	= 16,
+#define RTM_NEWLINK	RTM_NEWLINK
+	RTM_DELLINK,
+#define RTM_DELLINK	RTM_DELLINK
+	RTM_GETLINK,
+#define RTM_GETLINK	RTM_GETLINK
+	RTM_SETLINK,
+#define RTM_SETLINK	RTM_SETLINK
+
+	RTM_NEWADDR	= 20,
+#define RTM_NEWADDR	RTM_NEWADDR
+	RTM_DELADDR,
+#define RTM_DELADDR	RTM_DELADDR
+	RTM_GETADDR,
+#define RTM_GETADDR	RTM_GETADDR
+
+	RTM_NEWROUTE	= 24,
+#define RTM_NEWROUTE	RTM_NEWROUTE
+	RTM_DELROUTE,
+#define RTM_DELROUTE	RTM_DELROUTE
+	RTM_GETROUTE,
+#define RTM_GETROUTE	RTM_GETROUTE
+
+	RTM_NEWNEIGH	= 28,
+#define RTM_NEWNEIGH	RTM_NEWNEIGH
+	RTM_DELNEIGH,
+#define RTM_DELNEIGH	RTM_DELNEIGH
+	RTM_GETNEIGH,
+#define RTM_GETNEIGH	RTM_GETNEIGH
+
+	RTM_NEWRULE	= 32,
+#define RTM_NEWRULE	RTM_NEWRULE
+	RTM_DELRULE,
+#define RTM_DELRULE	RTM_DELRULE
+	RTM_GETRULE,
+#define RTM_GETRULE	RTM_GETRULE
+
+	RTM_NEWQDISC	= 36,
+#define RTM_NEWQDISC	RTM_NEWQDISC
+	RTM_DELQDISC,
+#define RTM_DELQDISC	RTM_DELQDISC
+	RTM_GETQDISC,
+#define RTM_GETQDISC	RTM_GETQDISC
+
+	RTM_NEWTCLASS	= 40,
+#define RTM_NEWTCLASS	RTM_NEWTCLASS
+	RTM_DELTCLASS,
+#define RTM_DELTCLASS	RTM_DELTCLASS
+	RTM_GETTCLASS,
+#define RTM_GETTCLASS	RTM_GETTCLASS
+
+	RTM_NEWTFILTER	= 44,
+#define RTM_NEWTFILTER	RTM_NEWTFILTER
+	RTM_DELTFILTER,
+#define RTM_DELTFILTER	RTM_DELTFILTER
+	RTM_GETTFILTER,
+#define RTM_GETTFILTER	RTM_GETTFILTER
+
+	RTM_NEWACTION	= 48,
+#define RTM_NEWACTION   RTM_NEWACTION
+	RTM_DELACTION,
+#define RTM_DELACTION   RTM_DELACTION
+	RTM_GETACTION,
+#define RTM_GETACTION   RTM_GETACTION
+
+	RTM_NEWPREFIX	= 52,
+#define RTM_NEWPREFIX	RTM_NEWPREFIX
+	RTM_GETPREFIX	= 54,
+#define RTM_GETPREFIX	RTM_GETPREFIX
+
+	RTM_GETMULTICAST = 58,
+#define RTM_GETMULTICAST RTM_GETMULTICAST
+
+	RTM_GETANYCAST	= 62,
+#define RTM_GETANYCAST	RTM_GETANYCAST
+
+	RTM_MAX,
+#define RTM_MAX		RTM_MAX
+};
 
 /* 
    Generic structure for encapsulation of optional route information.

--BXVAT5kNtrzKuDFl--
