From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: [PATCH 06/15] batman-adv: Distributed ARP Table
 - add snooping functions for ARP messages
Date: Tue, 1 May 2012 00:22:30 +0200
Message-ID: <20120430222226.GB21977@ritirata.org>
References: <1335689867-8017-1-git-send-email-ordex@autistici.org>
	<1335689867-8017-7-git-send-email-ordex@autistici.org>
	<20120430.130555.48557916635285475.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kORqDWCi7qDJ0mEj"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120430.130555.48557916635285475.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--kORqDWCi7qDJ0mEj
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 30, 2012 at 01:05:55 -0400, David Miller wrote:
> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Date: Sun, 29 Apr 2012 10:57:38 +0200
>=20
> > In case of an ARP message going in or out the soft_iface, it is interce=
pted and
> > a special action is performed. In particular the DHT helper functions p=
reviously
> > implemented are used to store all the ARP entries belonging to the netw=
ork in
> > order to provide a fast and unicast lookup instead of the classic broad=
cast
> > flooding mechanism.
> > Each node stores the entries it is responsible for (following the DHT r=
ules) in
> > its soft_iface ARP table. This makes it possible to reuse the kernel da=
ta
> > structures and functions for ARP management.
> >=20
> > Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
>=20
> Sorry, I'm not letting subsystems outside of net/ipv4/arp.c and related
> code make changes to the ARP table.
>=20
> I plan to make major surgery to the way neighbour table entries are
> handled and therefore the less people who get their grubby paws
> directly in there, the better.
>=20
> Find a way to propagate the ARP packet into the properl ARP receive
> path to cause the state update to occur, I'm not letting you trigger
> it by hand in the batman-adv code.
>=20
> Sorry.


Hello David,

I perfectly understand. We did it that way because we thought that we could=
 use
the exported API.

At this point, in my honest opinion, it is better to postpone this new feat=
ure
for a later pull request.

However this patch also contains a procedure which queries the neigh table =
in
order to understand whether a given host is known or not.
Would it be possible to do that in another way (Without manually touching t=
he
table)?

Instead, in the next patch (patch 06/15) batman-adv manually increase the n=
eigh
timeouts. Do you think we should avoid doing that as well? If we are allowe=
d to
do that, how can we perform the same operation in a cleaner way?

Last question: why can't other modules use exported functions? Are you goin=
g to
change them as well?


Thank you very much,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--kORqDWCi7qDJ0mEj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQEcBAEBAgAGBQJPnxCiAAoJEFMQTLzJFOZFbdMH/30qwasPB4h9FKaA3CIAkgfQ
6tWWzfjQ4ljHHmCwLzlo9lfcvzjuMxg6ly37RzGrPeSbzWZYdfeU6a9AqVokHkns
A3sCX1fDrfYTiyIftg47b7TW2oq7729CgxpsPil7yPJjN31a0jiL1qKILKFUvE7Q
hcOrN4TWqoVoHouEGAAaPJFBDQSQaNvdOI/MSRaoVg9Z6IjwdLoRGapzL4bsJwuw
o+306I2zq2FgK1LC/cdDmHVmLzKDTQ2K9CTsEX+Oit56HI+D7Fm49Qpe9TCVhQEs
zLvZG8ZGDY66x13hBLMoQtMc+d9Hh4OJdsA2CeoFuhWWVFtyuZO16bl9yH1gvn4=
=w6xQ
-----END PGP SIGNATURE-----

--kORqDWCi7qDJ0mEj--
