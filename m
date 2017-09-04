From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] e1000e: changed some expensive calls of udelay to
 usleep_range
Date: Mon, 4 Sep 2017 18:25:55 +0200
Message-ID: <20170904162555.GB21849@amd>
References: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="pvezYHf7grwyp3Bc"
Cc: jeffrey.t.kirsher@intel.com, michael.kardonik@nxp.com,
        carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
        bruce.w.allan@intel.com, john.ronciak@intel.com,
        mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthew Tan <matthew.tan_1@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pvezYHf7grwyp3Bc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> @@ -183,7 +183,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32=
 offset, u16 *data)
>  	 * reading duplicate data in the next MDIC transaction.
>  	 */
>  	if (hw->mac.type =3D=3D e1000_pch2lan)
> -		udelay(100);
> +		usleep_range(90, 100);
> =20
>  	return 0;
>  }

Can you explain why shortening the delay is acceptable here?
									=09
> @@ -246,7 +246,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u3=
2 offset, u16 data)
>  	 * reading duplicate data in the next MDIC transaction.
>  	 */
>  	if (hw->mac.type =3D=3D e1000_pch2lan)
> -		udelay(100);
> +		usleep_range(90, 110);
> =20
>  	return 0;
>  }

And here?
										Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--pvezYHf7grwyp3Bc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmtfpMACgkQMOfwapXb+vKqVwCcCOkSlwtQhAxESF2Ni0XF01g5
YgQAnjuMWJdf40eHhRJKvRzS+f01qFPW
=ZIlb
-----END PGP SIGNATURE-----

--pvezYHf7grwyp3Bc--
