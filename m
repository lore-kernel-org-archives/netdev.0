From: Andras Kis-Szabo <kisza@securityaudit.hu>
Subject: [PATCH] Re: net/ipv6/exthdrs.c
Date: Tue, 18 Jun 2002 16:00:54 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020618160054.B12974@sch.bme.hu>
References: <20020618135149.A24751@sch.bme.hu> <Pine.LNX.4.44.0206181458340.26140-100000@netcore.fi> <20020618155021.A12974@sch.bme.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20020618155021.A12974@sch.bme.hu>
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by balu.sch.bme.hu id g5IE0sLL015705

Andras Kis-Szabo .................................... (2002. j=FAnius 18.=
)

 Hi!


> The ipv6_ext_hdr() could be exported? It would be usefull at the Netfil=
ter
> side.
> (And when we are there: the ipv6_skip_exthdr() should be exported, too.=
)
I attached the patch for this. (If accepted, the Netfilter will follow it=
s
behaviour and I'll modify the matches.)

Regards,

	kisza

--=20
    Andras Kis-Szabo       Security Development, Design and Audit
-------------------------/        Zorp, NetFilter and IPv6
 kisza@SecurityAudit.hu /-----Member of the BUTE-MIS-SEARCHlab---------->

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch

--- linux.old/net/ipv6/exthdrs.c	Tue Jun 18 15:54:19 2002
+++ linux/net/ipv6/exthdrs.c	Tue Jun 18 15:55:34 2002
@@ -20,6 +20,8 @@
  *				  tlv options.
  */
 
+#include <linux/config.h>
+#include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -804,4 +806,7 @@
 	*nexthdrp = nexthdr;
 	return start;
 }
+
+EXPORT_SYMBOL(ipv6_ext_hdr);
+EXPORT_SYMBOL(ipv6_skip_exthdr);
 

--y0ulUmNC+osPPQO6--
