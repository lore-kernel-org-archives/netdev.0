From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH] remove leading space in linux/skbuff.h
Date: Sun, 19 Sep 2004 00:45:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918224507.GA28794@suse.de>
References: <20040918223832.GA28730@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040918223832.GA28730@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Sun, Sep 19, Olaf Hering wrote:

>=20
> unifdef complains about the leading space.
=20
maybe the whole content can be in #ifdef __KERNEL__

Signed-off-by: Olaf Hering <olh@suse.de>

diff -purN linux-2.6.8/include/linux/skbuff.h linux-2.6.8.xxx/include/lin=
ux/skbuff.h
--- linux-2.6.8/include/linux/skbuff.h	2004-09-19 00:11:39.094174840 +020=
0
+++ linux-2.6.8.xxx/include/linux/skbuff.h	2004-09-19 00:42:48.187538697 =
+0200
@@ -13,6 +13,7 @@
=20
 #ifndef _LINUX_SKBUFF_H
 #define _LINUX_SKBUFF_H
+#ifdef __KERNEL__
=20
 #include <linux/config.h>
 #include <linux/kernel.h>
@@ -271,7 +272,7 @@ struct sk_buff {
 #ifdef CONFIG_NET_CLS_ACT
 	__u32           tc_verd;               /* traffic control verdict */
 	__u32           tc_classid;            /* traffic control classid */
- #endif
+#endif
=20
 #endif
=20
@@ -285,7 +286,6 @@ struct sk_buff {
 				*end;
 };
=20
-#ifdef __KERNEL__
 /*
  *	Handling routines are only of interest to the kernel
  */
--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
