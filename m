From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Fri, 12 Sep 2003 20:29:28 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309122023050.27849-100000@netcore.fi>
References: <1063361813.23778.419.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063361813.23778.419.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003, David Woodhouse wrote:
> On Fri, 2003-09-12 at 12:48 +0300, Pekka Savola wrote:
> > You might also want to check out the document which is documenting th=
e=20
> > deprecation (note, it's still a draft version, and likely to evolve a=
=20
> > lot), to learn about some of the problems of the site-locals:
> >=20
> > http://www.ietf.org/internet-drafts/draft-ietf-ipv6-deprecate-site-lo=
cal-00.txt
>=20
> It's interesting to see the arguments therein. I thought there might
> have been some valid ones I wasn't previously aware of, since I'm fairl=
y
> new to IPv6. That doesn't really seem to be the case -- all the
> arguments could apply just as well to RFC1918 too.

You have this wrong assumption that IPv6 is engineered with RFC1918 in=20
mind.  Site-locals were indeed that.  But the point of deprecating them=20
was to get *rid of* (at least to a degree) RFC1918 addresses in IPv6.

It's no use to reply in detail, except to correct two very bad=20
misunderstandings..

> =C2=A72.2 -- internal addresses 'leak'. Not if you apply even a modicum=
 of
> clue. Same as RFC1918 in IPv4. You don't let packets with private sourc=
e
> addresses outside your borders, and you don't put them in public DNS.=20

Leakage is used to refer to a lot more than just source/destination=20
addresses.  For example, addresses leak when you use a Peer-to-peer syste=
m=20
behind a NAT; addresses leak when you contact to an FTP server from behin=
d=20
a NAT, etc.  Addresses leaking inside the application is a much more=20
difficult problem.
=20
> =C2=A72.3 -- routing is hard. Let's go shopping. You have a global inte=
rnal
> network routed over crypto tunnels between multiple sites. And you can'=
t
> handle setting up the routing? Yeah, right.

There's a lot more to it.

Consider the case when you have a router which is part of *two* sites,
each from overlapping addresses.  Routing protocols and everything would=20
have to be modified to pass site identifiers in addition to the addresses=
. =20
This looks like a simple problem but it isn't, that's for sure.
=20
--=20
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
