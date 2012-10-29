From: Cyril Brulebois <kibi@debian.org>
Subject: Re: [PATCH] r8169: Fix WoL on RTL8168d/8111d.
Date: Mon, 29 Oct 2012 01:21:40 +0100
Message-ID: <20121029002140.GK6195@mraw.org>
References: <1351392414-32219-1-git-send-email-kibi@debian.org>
 <20121028230523.GA26778@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aqWxf8ydqYKP8htK"
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121028230523.GA26778@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--aqWxf8ydqYKP8htK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Francois Romieu <romieu@fr.zoreil.com> (29/10/2012):
> Cyril Brulebois <kibi@debian.org> :
> > This regression was spotted between Debian squeeze and Debian wheezy
> > kernels (respectively based on 2.6.32 and 3.2). The fix was inspired
> > by <http://www.spinics.net/lists/netdev/msg178543.html>, using
> > RTL_GIGA_MAC_VER_{25,26} for the RTL8168d/8111d chipset.
>=20
> If someone experiences problems or has questions about WoL with
> Realtek's 816x chipsets, http://marc.info/?t=3D132079219400004 would
> imho be a better reference.

Thanks. Should I re-send with that as reference, or will you amend the
patch once you're done with your testing?

> [...]
> > Tested on top of a 3.2.23 kernel.
>=20
> It should still be relevant for current kernel. I'll give it a try.

FWIW, further testing was suggested on some Debian lists, and 3.2.32
(which includes some commits related to r8169) is also affected.

> [...]
> > It looks like RTL_GIGA_MAC_VER_{25,26} are kinda supposed to go
> > together so I kept both. Florent's testing gave the following results:
> >  - RTL_GIGA_MAC_VER_25 only: FAIL.
> >  - RTL_GIGA_MAC_VER_26 only: SUCCESS.
> >  - RTL_GIGA_MAC_VER_25 + RTL_GIGA_MAC_VER_26: SUCCESS.
>=20
> I don't understand the VER_25 vs VER_26 difference.

Neither do I. We just figured that it would nice to test all three
cases since those two macros popped up when looking at the 8168D
family.

Mraw,
KiBi.

--aqWxf8ydqYKP8htK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlCNzAgACgkQeGfVPHR5Nd3bNgCdGk0pTyrS9cCOQVpr3xqMj/aX
N+sAoKRaBIZZFH9OHiNeFxH7CJFreMci
=JSky
-----END PGP SIGNATURE-----

--aqWxf8ydqYKP8htK--
