From: Andre Tomt <andre@tomt.net>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: 11 Jul 2003 03:49:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057888154.26854.324.camel@localhost>
References: <20030710154302.GE1722@zip.com.au>
	 <1057854432.3588.2.camel@hades>  <20030710233931.GG1722@zip.com.au>
	 <1057881869.3588.10.camel@hades>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Mika Liljeberg <mika.liljeberg@welho.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <1057881869.3588.10.camel@hades>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On fre, 2003-07-11 at 02:04, Mika Liljeberg wrote:
> Well, the thing is that prefix:: is a special anycast address that
> identifies a router on the link prefix::/n, where n is the prefix
> length. You had configured a 127-bit link prefix, meaning that you had
> only one valid unicast address (last bit =3D=3D 1) in addition to the r=
outer
> anycast address (last bit =3D=3D 0).

Thanks for the explanation, I've been struggling to understand what
Yoshfuji tried to explain to me earlier on this topic (see "IPv6 bugs
introduced in 2.4.21" - ie. my bogus bugreport), now it all makes
perfect sense :-)

> Normally, IPv6 networks are supposed to use 64-bit on-link prefixes but
> the implementation can be written in such a way that other prefix
> lengths can be configured.
>=20
> Setting your tunnel prefix to /64 is certainly the right thing to do.=20

If you don't have anything but one /64 for example.. I guess /126's
would be ok as you could rule out the the anycast address? It will
probably work with Linux - but is it wrong in any sense, other than
"breaking" with EUI-64/autoconfiguration?

--=20
Cheers,
Andr=E9 Tomt
andre@tomt.net
