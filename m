From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis-usagi1@simphalempin.com>
Subject: Re: (usagi-users 03224) Re: support of IPv6 by NFS
Date: Tue, 1 Mar 2005 19:39:49 +0100
Message-ID: <200503011939.50645.rdenis-usagi1@simphalempin.com>
References: <42243F8D.5030302@bull.net> <1109689712.17484.6.camel@firenze.zurich.ibm.com> <20050301161905.GD22324@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Olaf Kirch <okir@suse.de>, Jeroen Massar <jeroen@unfix.org>,
        netdev@oss.sgi.com
To: usagi-users@linux-ipv6.org
In-Reply-To: <20050301161905.GD22324@suse.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Le Mardi 1 Mars 2005 17:19, Olaf Kirch a =E9crit :
> > The protocol for Teredo is open and can be implemented at will:
>
> Except that it's quite horrible,

Yes, it is, and that's its biggest weakness. NAT traversal is horrible=20
by design. So either you use a point-to-point tunnel over UDP (or TCP,=20
but it is slow), either you end up with something horrible.

> and it requires a centralized broker,

Actually, Teredo is much more decentralised than, say, TSP. There could=20
be several Teredo relays among the IPv6 world, from different entities,=20
much like there are currently 6to4 relays.

The only centralized thing is the server whose only purpose is autoconf=20
and NAT traversal.

> and IIRC it also makes assumptions about the way your NAT
> implementation assigns ports.

Yes, indeed. Unfortunately, the only way to avoid such assumptions is to=20
use point-to-point IPv6 tunnels (or not try to use IPv6 from behind a=20
NAT at all).

Point-to-point tunneling might be fine, but, as far as I know, there is=20
no automatic and registration-less IPv6 point-to-point tunneling=20
solution at the moment :-(

--=20
R=E9mi Denis-Courmont
