From: William Dauchy <william@gandi.net>
Subject: Re: dynamically set number of queues for 82598 devices
Date: Tue, 3 Nov 2015 10:56:03 +0100
Message-ID: <20151103095603.GE7714@gandi.net>
References: <20151029152645.GD7657@gandi.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9l24NVCWtSuIVIod"
Cc: netdev@vger.kernel.org, Tal Abudi <talabudi@gmail.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, william@gandi.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:59082 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751289AbbKCJ4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 04:56:07 -0500
Content-Disposition: inline
In-Reply-To: <20151029152645.GD7657@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9l24NVCWtSuIVIod
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello David,

On Oct29 16:26, William Dauchy wrote:
> I faced the problem described in commit 7e3f5c8:
> ixgbe: fix bounds checking in ixgbe_setup_tc for 82598
>=20
> This patch resolves an issue where users were not able to dynamically
> set number of queues for 82598 via ethtool -L
>=20
> I backported it for my v4.1.x build but I was wondering if this could be
> a candidate for a backport in stable tree at least for v4.1.x.

Since we are now in a bug fix period, I was wondering if you could have
a look at commit 7e3f5c8 (ixgbe: fix bounds checking in ixgbe_setup_tc
for 82598)
I don't see it in
http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
so I was wondering if it could be a valid candidate for stable.

Best regards,
--=20
William

--9l24NVCWtSuIVIod
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlY4hLMACgkQ1I6eqOUidQEYigCgjIHYW8Fl/qHBsMwi9m/lOsnR
AbcAmwSmSxmOuZ/0Dag2I1/Pm6m8sAJT
=nvsI
-----END PGP SIGNATURE-----

--9l24NVCWtSuIVIod--
