From: Olaf Hering <olh@suse.de>
Subject: [PATCH] signed bug in net/decnet/dn_nsp_in.c dn_nsp_linkservice()
Date: Mon, 28 Jun 2004 20:18:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040628181843.GA15021@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


net/decnet/dn_nsp_in.c:534: warning: comparison is always false due to li=
mited range of data type

char can be either signed or unsigned, depending on the target system.
patch is against 2.6.7-bk11


--- ./net/decnet/dn_nsp_in.c
+++ ./net/decnet/dn_nsp_in.c	2004/06/28 18:11:40
@@ -504,7 +504,7 @@
 	struct dn_scp *scp =3D DN_SK(sk);
 	unsigned short segnum;
 	unsigned char lsflags;
-	char fcval;
+	signed char fcval;
 	int wake_up =3D 0;
 	char *ptr =3D skb->data;
 	unsigned char fctype =3D scp->services_rem & NSP_FC_MASK;
--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
