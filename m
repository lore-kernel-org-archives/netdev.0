From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv6] net: Add batman-adv meshing protocol
Date: Wed, 1 Dec 2010 19:54:19 +0100
Message-ID: <201012011954.20275.sven.eckelmann@gmx.de>
References: <1289136377-18350-1-git-send-email-sven.eckelmann@gmx.de>
	<20101201.104314.112592938.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart99328296.uIy46cv9Gi";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20101201.104314.112592938.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

--nextPart99328296.uIy46cv9Gi
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
> Date: Sun,  7 Nov 2010 14:26:17 +0100
>=20
> > +		if (seq_bits[word_num] & 1 << word_offset)
>=20
>  ...
>=20
> > +	seq_bits[word_num] |=3D 1 << word_offset;	/* turn the position on */
>=20
>  ...
>=20
> > +#define TYPE_OF_WORD unsigned long
>=20
> "1" is an 'int' and won't get promoted to unsigned long which means
> this code won't work on 64-bit, you need to explicitly say "1UL".

Thanks, that's correct. Will be replaced by the kernel facilities.

[...]
> The badman-adv code is full of duplicated functionality, and until
> all of these cases are cured I refuse to integrate this code.  I
> already complained about the hashing stuff, and now there's this
> stuff too.
>=20
> Every time I review the batman-adv code I find a bug, and the bug is
> often in facilities which the kernel has already and are being
> duplicated.  That is by definition a waste of my and everyone else's
> time.
>=20
> Probably your submission will be almost half the size that it is
> currently once you take care of this issue. :-)

Do you have any more possible duplication you have in your mind right now?

thanks,
	Sven

--nextPart99328296.uIy46cv9Gi
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJM9pncAAoJEF2HCgfBJntGu38P/ROjRgeha2yUwjCGrOGl/Vw2
MHIwxgRfjftTzkc8t/JEe8C7mFuxzdzzMOaDRG4ECpcEL6zMhr2ANXl3HaVb3Qr4
u4hSuhJvzWFnIMwhNod47XPXddqoGLdu/8nRSSMKyzUMvg1Hnrj5Gp3CS+w+muoj
TGqxP1wOuZAXZB64zx9yOcQTDtn/JXnv5Tyaf3Y6dnDRTsjhhY3zcWVr1hisTqDX
KZqtD+vxcngfL/7p5kNkd5IpVwhgTk07mHs2FHDqLALjWF7D7WwRwc2Q9Ky2H0Ww
rd6yB/AN6L1cSC0vlLUZtQzMFHA9eECDBi5UVKNrBOVlknbfBIMQeTm803z7w6CO
oNcd5gcEiAM0Zh+uL6jzfiHu4nDaFOppMAjqTw3E+HL4RcJVw0sOoWgKoMYa5iF+
xPG/7MdWLH7WT2GTT+NKjekgrJ9PO4PmDjDWkqK4vtV/+azmou6+WGxpfRyXdWve
FHy3eFGzTaPQ35ODTKYrnsJ4DHys4UeJHnkt+vRCFhjaO4QkG43LkKd+iP2Fs01M
rT1LGZnSjG2Li5n54AKdIL5TriMmNa+aAWtZgRMFDXI4je5srWi694MBBdIml64c
dVfT4CIkV98SFhXF/O0gxzY43UH/LSkzGqprMXzAL5lPA8s6NVDxyWhnq8BeH4PV
j4oSIi2nFun3Vs54i2Tc
=bkfB
-----END PGP SIGNATURE-----

--nextPart99328296.uIy46cv9Gi--
