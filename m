From: Andre Tomt <andre@tomt.net>
Subject: Re: IPv6 bugs introduced in 2.4.21
Date: 18 Jun 2003 16:10:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055945454.7480.184.camel@slurv.ws.pasop.tomt.net>
References: <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net>
	 <20030618.224257.130940019.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030618.224257.130940019.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On ons, 2003-06-18 at 15:42, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> In article <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net> (at 16 =
Jun 2003 21:50:48 +0200), Andre Tomt <andre@skjellin.no> says:
>=20
> > I mailed you guys a little while ago on the "unable to use
> > SOMENETWORK::0000 as a nexthop gateway" bug in 2.4.21-pre/rc a while
> > ago. It is still present in 2.4.21, rendering the "first" /128 of a
> > arbitrary prefixlen unusable - :0000. This is especially bad with /12=
7
> > tunnels, rendering :0000 and :0001 unusable). But! There is one more
> :
>=20
> This is NOT the bug but by the spec.
> prefix:: is an anycast address, not a unicast;
> you cannot use it like an unicast address.

Ok, that probably is correct. It works in 2.4.20, that does not mean
it's correct behavior though ;-)

> Well...
>=20
> Do you really need to assign global address on the point-to-point devic=
e?

Yes.

> If yes, you should not use /127 prefix; please use /64 instead.

No one in their right mind assigns /64's for a linknetwork with two
peers. It's a pointopoint-link. All people I know use either /128
pointopoint or pointomultipoint semantics (BSD, KAME), or /127's as
Linux refuses to use the traditional pointopoint or peer parameter in
ifconfig and iproute for ipv6.

The /127 matches both 2a and 2b, why does it end up at localhost?
