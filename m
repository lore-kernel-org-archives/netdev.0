From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: how to use secure_tcp_sequence_number
Date: Thu, 30 Sep 2010 20:21:01 +0200
Message-ID: <1285870861.2615.946.camel@edumazet-laptop>
References: <AANLkTimA6jJbCvtxFi41JbH_XSJtKo0FrDE=fQ2OiafY@mail.gmail.com>
	 <AANLkTikWop213k7cBXAaoCMw_8LouX-qauYEbHD=d1Vh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikWop213k7cBXAaoCMw_8LouX-qauYEbHD=d1Vh@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 septembre 2010 =C3=A0 19:01 +0200, Nicola Padovano a =C3=A9=
crit :
> If i attempt to insert the module that uses the
> secure_tcp_sequence_number i get this error message:
>=20
> from insmod:  -1 Invalid module format
> and from dmesg: version magic '2.6.35.4 SMP mod_unload 586 ' should b=
e
> '2.6.35.4 SMP mod_unload modversions 586 '
>=20
> what's the matter?

diff --git a/drivers/char/random.c b/drivers/char/random.c
index caef35a..f5ef7ba 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1550,6 +1550,7 @@ __u32 secure_tcp_sequence_number(__be32 saddr, __=
be32 daddr,
=20
 	return seq;
 }
+EXPORT_SYMBOL(secure_tcp_sequence_number);
=20
 /* Generate secure starting point for ephemeral IPV4 transport port se=
arch */
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dpor=
t)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
