From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the wireless tree with Linus' tree
Date: Tue, 17 Aug 2010 13:07:22 +1000
Message-ID: <20100817130722.cd8c11b0.sfr@canb.auug.org.au>
References: <20100817115203.e8a76e44.sfr@canb.auug.org.au>
	<201008171229.46175.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__17_Aug_2010_13_07_22_+1000_mvQO/kDifi5bPJbC"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <201008171229.46175.rusty@rustcorp.com.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__17_Aug_2010_13_07_22_+1000_mvQO/kDifi5bPJbC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Rusty,

On Tue, 17 Aug 2010 12:29:44 +0930 Rusty Russell <rusty@rustcorp.com.au> wr=
ote:
>
> You can drop the commit as you have done.  But it leaves three problematic
> writable charp parameters in the libertas/ directory which now need lifet=
ime
> management.
>=20
> ie. kparam_block_sysfs_write()/unblock around them, and probably they need
> to be copied.

I figured that there was something needed, but I could not figure out where.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__17_Aug_2010_13_07_22_+1000_mvQO/kDifi5bPJbC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMafzqAAoJEDMEi1NhKgbsz/MH/2+KQG759Xe65MYG3jf9hdPY
J1Vwya4UMshfWxmUVL9Ivji8wy6XLKM0nTv2z0MuAvOspBoMb7X0UxwMfBMnIClh
XK2f2S2ZKMYjLuulK7qF9Jjy/vkxsQtbjqZSEndrFzBKYtq0kkFJv/KYwpZC9oaU
q6aOW269HkbwLdl1EMjLqKikRvc7ymzxtWPq6vihnWxDCeQyepHv2TFe7AUSOoGl
aaLWJ3EB/nBVJQfvKEcySGjNskkSTViiGN5tMV7sqxetc9pEVpO2o76ZCoyWxhBl
ZxSoIGkYunezJH3Xd4baokWza0Y8TK7dUEUqV8PaQ1pVnlEfVustlhPY7BWfnz4=
=x2fH
-----END PGP SIGNATURE-----

--Signature=_Tue__17_Aug_2010_13_07_22_+1000_mvQO/kDifi5bPJbC--
