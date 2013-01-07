From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#697357: bridging broken over bond interfaces
Date: Mon, 07 Jan 2013 04:58:24 +0000
Message-ID: <1357534704.26822.6.camel@deadeye.wl.decadent.org.uk>
References: <20130104111712.25539.62770.reportbug@valiant.palfrader.org>
	 <20130104114407.GA303@waldi.eu.org>
	 <20130104124012.GH14827@anguilla.noreply.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7JTQ5S3aTaGLVIrBfy+W"
Cc: Bastian Blank <waldi@debian.org>, 697357@bugs.debian.org,
	Peter Palfrader <weasel@debian.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58110 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753574Ab3AGE6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 23:58:31 -0500
In-Reply-To: <20130104124012.GH14827@anguilla.noreply.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7JTQ5S3aTaGLVIrBfy+W
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Forwarding this to netdev since the bug is still present in Linux 3.7.1.
For those joining us, this thread is archive at
<http://bugs.debian.org/697357>.

On Fri, 2013-01-04 at 13:40 +0100, Peter Palfrader wrote:
> On Fri, 04 Jan 2013, Bastian Blank wrote:
>=20
> > On Fri, Jan 04, 2013 at 12:17:12PM +0100, Peter Palfrader wrote:
> > > I tried to set up a new KVM host in the usual way:
> > >   - have a bond0 interface over all physcial eth* interfaces
> > >   - create a br0 over that bond0 and any vnet* interfaces for the
> > >     guests.
>=20
> Also, arp works through the bridge, forgot to mention that.
>=20
> > > *   Manually switching the eth* to promiscious mode makes stuff work.
> >=20
> > Okay, so a workaround is available.
> >=20
> > When did it last work? Does it work with the kernel from experimental?
>=20
> It works nicely on stable, e.g. pasquini.debian.org:
>=20
> | weasel@pasquini:~$ sudo brctl show
> | bridge name     bridge id               STP enabled     interfaces
> | br0             8000.e83935a9ec10       no              bond0
> |                                                         tap0
> |                                                         tap1
> |                                                         tap2
> | br1             8000.e83935a9ec10       no              bond0.221
> | br2             8000.da1343affe92       no              bond0.3301
> |                                                         tap3
>=20
> And there the bond interface is promisc automatically:
> weasel@pasquini:~$ ip a | grep -i bond
> | 2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_f=
ast master bond0 state UP qlen 1000
> | 3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_f=
ast master bond0 state UP qlen 1000
> | 4: bond0: <BROADCAST,MULTICAST,PROMISC,MASTER,UP,LOWER_UP> mtu 1500 qdi=
sc noqueue state UP=20
> | 7: bond0.221@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 q=
disc noqueue state UP=20
> | 9: bond0.3301@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 =
qdisc noqueue state UP=20
>=20
> Likewise it works as expected when one does br directly on eth0, without =
any
> bonding.
>=20
> It's also broken with linux-image-3.7-trunk-amd64_3.7.1-1~experimental.1_=
amd64.deb.

--=20
Ben Hutchings
If you seem to know what you are doing, you'll be given more to do.

--=-7JTQ5S3aTaGLVIrBfy+W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUOpV8Oe/yOyVhhEJAQqu5hAA0Geaj3/GPLl66PIYgwoT605NxhiwhxZB
3fBvnvEGRdZN5KSJMbYv58dY0VxD4XFHIeQZGSg4NF7hI6yvMw8mjxftbE6PsCKb
fcrSjdU/MfQgDRjmuPjiRSOUzNAKNoP+3jNBNH0FdQ//riBxR+OKnuASiPhDH3SD
cOgjl276iWvNaBCCC2M6BMikCBh+rIB+TNW5I9jlEjIsCv9WAJ12WHG7l9494+5s
epMkL2QhkadXmkDQxK8U211k5isJzXLRyGbQdhfQ1Z/UjlsHK8n/6O8/sXNsRDON
UDaMC4qldVWRPtE3mpSYSuS+MTWPyH2E9H2Otg8U4q1PFhVW6tOFUfnQnIE3M1i3
247OVcoqyFjgUK7Oa8+HrmAMlCtN1Pq/CO/lNQE9xhcsA73ObQb1HN2iiMjrU/49
wSk6VGRWxZ8K1Y3mLqs//0ucNSUD7lWobLWEJeso8b3Edm0ZtbvWKVfa9CaCV2Rl
WV0ywXdVZkUSD43CX33A416vvm7Dl5BPyRNKmnIW/yYmJfyut+sf20dQhJi4Bs/O
KQ+tGUmlXyL8OOXxSw15D762Kh6TUjNVVkL1bP5uxsJs8bSwF1ePx1LWnLw70raI
ne4vyJj8Xf2TQ3/Po2O+tTmSEKxxT2XhVevpZsB3CXlnQj6Vrb0XV0N6u5brsisH
nbMd0Z9dmGc=
=2KlK
-----END PGP SIGNATURE-----

--=-7JTQ5S3aTaGLVIrBfy+W--
