From: Patrick McHardy <kaber@trash.net>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 03 May 2005 00:04:48 +0200
Message-ID: <4276A400.2050306@trash.net>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505021659.05674.hasso@estpak.ee> <42763E96.1070209@trash.net> <200505022038.22014.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200505022038.22014.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> Patrick McHardy wrote:
>=20
>>Why can't you simply add the prefered source address to the route?
>=20
> Because I don't know what it is. Router A knows what's the best path fr=
om=20
> router A to router B, but he can't know (at least in cases where there =
are=20
> more than 1 path between them) what's the best path from router B to ro=
uter=20
> A. Therefore you can=E4t say which one is incoming interface in router =
A for=20
> traffic from router B. And even if you know it in some moment, topology=
=20
> might change in next moment (dynamic routing) etc.

Your patch can't guarantee that the address used is the same that was
used as nexthop by the previous hop in the path when multiple addresses
are configured on the incoming interface. So I don't think it achieves
much of your goal of making debugging complicated topologies easier.

Regards
Patrick
