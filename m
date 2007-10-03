From: Ian Kumlien <pomac@vapor.com>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Wed, 03 Oct 2007 09:37:36 +0200
Message-ID: <1191397056.26233.24.camel@localhost>
References: <1191372129.26233.12.camel@localhost>
	 <20071002180209.47c350a3@freepuppy.rosehill>
	 <1191375274.26233.17.camel@localhost>
	 <20071002215914.13d1e8cf@freepuppy.rosehill>
Reply-To: pomac@vapor.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7XHyictprzcCrlQ7zpwQ"
Cc: Jeff Garzik <jgarzik@pobox.com>, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:35042 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbXJCHhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 03:37:53 -0400
In-Reply-To: <20071002215914.13d1e8cf@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7XHyictprzcCrlQ7zpwQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On tis, 2007-10-02 at 21:59 -0700, Stephen Hemminger wrote:
> On Wed, 03 Oct 2007 03:34:34 +0200
> Ian Kumlien <pomac@vapor.com> wrote:
>=20
> > On tis, 2007-10-02 at 18:02 -0700, Stephen Hemminger wrote:
> > > Remove unneeded check that caused problems with jumbo frame sizes.
> > > The check was recently added and is wrong.
> > > When using jumbo frames the sky2 driver does fragmentation, so
> > > rx_data_size is less than mtu.
> >=20
> > Confirmed working.
> >=20
> > Now running with 9k mtu with no errors, =3D)
> >=20
> > It also seems that the FIFO bug was the one that affected me before,
> > damn odd race that one.
>=20
> Does the workaround (forced reset work). Ian, you are the first person to
> report triggering it.  I haven't found a way to make it happen.
> What combination of flow control and speeds are you using?

Yes it works, it's the problem i had all along =3D)

As to how to make it happen thats a bit harder...
To me it seems like it's a combination of several connections and
somewhat high bandwidth but you have to send data for it to happen...

To me it usually happens when seeding files via Bittorrent, but it seems
like it has to be somewhat special circumstances to actually trigger it.

I use jumbo frames, my lan is gigabit, to my firewall. From the firewall
it's common 1500 mtu 100mbit and i doubt that this has anything to do
with it (if it's not a 'number of frames that can be stored' problem and
thus the mtu limits it to a really small value making it easier to
trigger)

Well, thats my thoughts atleast but then i just got up after having
slept 5 hours, so =3D)

--=20
Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

--=-7XHyictprzcCrlQ7zpwQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7-ecc0.1.6 (GNU/Linux)

iD8DBQBHA0bA7F3Euyc51N8RAgUpAJ9/LCBVM9t7NUEAtIkf9HbgWYEB1ACgk0UZ
nxa6rdbbv3wAsEjtB8ShMkU=
=wSYY
-----END PGP SIGNATURE-----

--=-7XHyictprzcCrlQ7zpwQ--

