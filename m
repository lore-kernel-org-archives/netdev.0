From: Olaf Hering <olh@suse.de>
Subject: [PATCH] remove leading space in linux/skbuff.h
Date: Sun, 19 Sep 2004 00:38:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918223832.GA28730@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


unifdef complains about the leading space.

Signed-off-by: Olaf Hering <olh@suse.de>


diff -purN linux-2.6.8/include/linux/skbuff.h linux-2.6.8.xxx/include/lin=
ux/skbuff.h
--- linux-2.6.8/include/linux/skbuff.h	2004-09-19 00:11:39.094174840 +020=
0
+++ linux-2.6.8.xxx/include/linux/skbuff.h	2004-09-19 00:30:14.332978660 =
+0200
@@ -271,7 +271,7 @@ struct sk_buff {
 #ifdef CONFIG_NET_CLS_ACT
 	__u32           tc_verd;               /* traffic control verdict */
 	__u32           tc_classid;            /* traffic control classid */
- #endif
+#endif
=20
 #endif
=20
--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
