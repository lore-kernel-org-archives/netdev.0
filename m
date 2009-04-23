From: Ben Hutchings <ben@decadent.org.uk>
Subject: RE: e1000e NVM mutex contention warnings
Date: Fri, 24 Apr 2009 00:14:44 +0100
Message-ID: <1240528484.3605.39.camel@deadeye.i.decadent.org.uk>
References: <1240147024.3384.20.camel@deadeye.i.decadent.org.uk>
	 <F169D4F5E1F1974DBFAFABF47F60C10A29F7BE99@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-xl2A8LBGGI6Fc2qAGPQK"
Cc: "Graham, David" <david.graham@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"524699@bugs.debian.org" <524699@bugs.debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41654 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753681AbZDWXOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 19:14:52 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A29F7BE99@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xl2A8LBGGI6Fc2qAGPQK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-04-23 at 15:15 -0700, Brandeburg, Jesse wrote:
> Ben Hutchings wrote:
> > What's your plan for collecting information about NVM mutex contention
> > and when do you intend to remove the warnings?  I have to say I find
> > this way of testing very user-unfriendly and would like to see it gone
> > as soon as possible.
>=20
> Hi Ben,
>=20
> checking linus' tree and davem's current net-2.6 tree shows that the
> code was removed as of commit: 0a834a36ac92375cd82d9e4fe4f571e257997d6a
>=20
> it was put in 2/14/2009, and was included in 2.6.30-rc1 by linus.

Thanks.  I had a look but somehow missed that this was already on the
way out in 2.6.30.

> are you suggesting that we maybe try to push to -stable too?

If you now have the information you need about contention, then it seems
to me that it would be worthwhile to remove the unnecessary warnings.
If you don't want to submit a stable update then I can patch it out in
the Debian kernel package.

Ben.


--=-xl2A8LBGGI6Fc2qAGPQK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBJ8PZg79ZNCRIGYgcRAj4vAJ4tq+EBNkCvuYE3R3RHsMQi4Co0MACgwMhf
11vKMlgpOduFXMs2ds0VESo=
=2wBI
-----END PGP SIGNATURE-----

--=-xl2A8LBGGI6Fc2qAGPQK--
