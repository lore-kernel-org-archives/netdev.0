From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: IPv6: Bug in net-next
Date: Wed, 8 Jan 2014 05:18:46 -0800 (PST)
Message-ID: <1389187126.20074.YahooMailBasic@web125504.mail.ne1.yahoo.com>
References: <1389186135.88856.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm47.bullet.mail.ne1.yahoo.com ([98.138.120.54]:39730 "HELO
	nm47.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755610AbaAHNVh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 08:21:37 -0500
In-Reply-To: <1389186135.88856.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1/8/14, Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:

> Hello,
=20
> I think there is a bug in actual net-next.
=20
> When I execute this code and press Crtl-C, all the IPv6
> Link-Layer addresses are deleted.
=20
> This happened between
> c1ddf295f5183a5189196a8035546842caa2055a and HEAD.
=20
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <net/if.h>
>=20
> int main (int argc, char **argv)  {
> =A0 struct ipv6_mreq mreq =3D { 0 };
> =A0 int sockfd1 =3D socket (AF_INET6, SOCK_DGRAM, 0);
>=20
> =A0 inet_pton (AF_INET6, "2a01:999::1", &mreq.ipv6mr_multiaddr);
> =A0 mreq.ipv6mr_interface =3D if_nametoindex ("dummy0");
> =A0 setsockopt (sockfd1, IPPROTO_IPV6, IPV6_JOIN_ANYCAST, &mreq, size=
of (mreq));
>=20
> =A0 pause ();
> }
=20
Sorry, it is not linked to this code.
I'm looking for the reason ...

BR,
=46rancois-Xavier
