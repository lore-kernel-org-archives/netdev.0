From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 12/14] mlx4: use netdev_rss_key_fill() helper
Date: Sun, 23 Nov 2014 04:07:31 +0000
Message-ID: <1416715651.7215.43.camel@decadent.org.uk>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
	 <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AGx4fLABdG6SdqwH/Voa"
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45640 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbaKWEHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 23:07:53 -0500
In-Reply-To: <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AGx4fLABdG6SdqwH/Voa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 15:58 -0800, Eric Dumazet wrote:
> On Sat, 2014-11-22 at 21:49 +0000, Ben Hutchings wrote:
> > On Sun, 2014-11-16 at 06:23 -0800, Eric Dumazet wrote:
> > > Use of well known RSS key increases attack surface.
> > > Switch to a random one, using generic helper so that all
> > > ports share a common key.
> > >=20
> > > Also provide ethtool -x support to fetch RSS key
> > [...]
> > > @@ -1799,6 +1805,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops =
=3D {
> > >  	.get_rxnfc =3D mlx4_en_get_rxnfc,
> > >  	.set_rxnfc =3D mlx4_en_set_rxnfc,
> > >  	.get_rxfh_indir_size =3D mlx4_en_get_rxfh_indir_size,
> > > +	.get_rxfh_key_size =3D mlx4_en_get_rxfh_key_size,
> > >  	.get_rxfh =3D mlx4_en_get_rxfh,
> > >  	.set_rxfh =3D mlx4_en_set_rxfh,
> > [...]
> >=20
> > A driver that implements get_rxfh_key_size() and set_rxfh() is assumed
> > to support setting the RSS key (and only the key).  However,
> > mlx4_en_set_rxfh() will currently crash if a new indirection table is
> > not provided.
>=20
> Hi Ben.
>=20
> Is this a net-next only concern, or is it an existing problem in net
> tree ?

It's introduced by the above patch, as you seem to have worked out.
Drivers not implementing ethtool_ops::get_rxfh_key_size will always get
a non-null indir pointer (see commit 61d88c6811f2).

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-AGx4fLABdG6SdqwH/Voa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHFdh+e/yOyVhhEJAQr4mQ//XClFFJidC8uel2uKb++NJ9dFLCArsI0x
K8yTGJiWqpMjImySIP6tbRhhDl0MTDY0bYPrXMs0YpIkHiLo9JMx+bPdM/7FKVWs
Nqn33z0qzmaueCr0FYdRoXtFK/79tdL9gy35FyvNbBAx436+xGBECh5AquwLOj1O
BHsP0O8q8iytZt/DjZmBuvFY7YtfF5qRs0kSP4UVstzuWdfhXfyqIvSKchRWhd9U
K7IsILEWhpr1ZjufAZPqaWW21rnb6ffaLdsYityOJZXqM3t8MTkOG1c/EpbhBWOy
Mmas5M6a25Y477sS9a9s9TTbDAdZwVUNDQ3PQ0wYVBzVAMCE7Dt3MgIi7TUQVRfT
iMltJ3zvITC9uSZo9N1q7BzcGnzXSkvdaUvaPIf6UAEYlHKGYgIgbystUHUWq2Cq
+YYCGqrJOTI72mc2NLuUozRdx8U32U0gdpszsomp9voOta/tstFJfFZppyemvt72
P8kQdxGd+V7Yf3NfeXdk7Kunw5jFRCngd25zYs7pYDVpAy8u8F93hojusFHy9Kn3
pxwT1C8CQ4cfn8n9fEi56urS0vA6CgP71pktpYmiZ8LdRsrbVRihUt25E/K/lYvw
+Qm4YBSpoeUQqW9oQBmCI/aUC0Cq0n6ErpGbGP2e8vH3ZbnR7e0XuX2raWyeuphL
SS4+gbuXeh4=
=MzkL
-----END PGP SIGNATURE-----

--=-AGx4fLABdG6SdqwH/Voa--
