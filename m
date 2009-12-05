From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 06/31] Constify struct e1000_mac_operations for 2.6.32
 v1
Date: Sat, 5 Dec 2009 11:40:48 +1100
Message-ID: <20091205114048.37df384e.sfr@canb.auug.org.au>
References: <4B198670.2000406@gmail.com>
	<4B198A33.7080705@gmail.com>
	<4B19A337.6060808@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__5_Dec_2009_11_40_48_+1100_FsPW.pWV84JZiWzZ"
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:54178 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564AbZLEAkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 19:40:47 -0500
In-Reply-To: <4B19A337.6060808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sat__5_Dec_2009_11_40_48_+1100_FsPW.pWV84JZiWzZ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Emese,

On Sat, 05 Dec 2009 01:03:03 +0100 Emese Revfy <re.emese@gmail.com> wrote:
>
> --- a/drivers/net/e1000e/82571.c
> +++ b/drivers/net/e1000e/82571.c
> @@ -212,6 +212,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_a=
dapter *adapter)
>  {
>  	struct e1000_hw *hw =3D &adapter->hw;
>  	struct e1000_mac_info *mac =3D &hw->mac;
> +	/* cannot be const */
>  	struct e1000_mac_operations *func =3D &mac->ops;

Adding to the comment to say why it can't be const may allow us to fix
this later ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Sat__5_Dec_2009_11_40_48_+1100_FsPW.pWV84JZiWzZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksZrBAACgkQjjKRsyhoI8z09wCfUmY5uM7Vgp7CMDLOjHMVK6bC
VxgAoJ8Pd6zjO1RWy5S+j91W3k7FVXdI
=4VE8
-----END PGP SIGNATURE-----

--Signature=_Sat__5_Dec_2009_11_40_48_+1100_FsPW.pWV84JZiWzZ--
