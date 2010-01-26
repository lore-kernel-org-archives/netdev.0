From: Henning Rogge <henning.rogge-FCsFpRLaMoKatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: Re: Network QoS support in applications
Date: Tue, 26 Jan 2010 14:06:59 +0100
Message-ID: <201001261407.04947.henning.rogge@fkie.fraunhofer.de>
References: <87k4v5nuej.fsf@purkki.valot.fi> <20100126.041610.226004766.davem@davemloft.net> <87wrz5m3cd.fsf@purkki.valot.fi>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4303306.S5F0AqoMOV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87wrz5m3cd.fsf-ySPBbPOLdCfMApvqMRVM/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart4303306.S5F0AqoMOV
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Tue January 26 2010 13:56:50 Kalle Valo wrote:
> So the idea is that the three left most bits (Class Selector
> Codepoints from DiffServ RFC 2474) would contain these values from
> IEEE 802.1d-2004 Annex G:
>=20
> 0 best effort
> 1 background
> 2 (spare)
> 3 excellent effort
> 4 controlled load
> 5 video
> 6 voice
> 7 network control
>=20
> What do people think of this?
The IETF is discussing about a traffic priority below "best effort" for bul=
k=20
traffic at the moment. Something you use to fill up links if your can but d=
rop it=20
if you are not sure. So it might be a good idea to make "best efford" not z=
ero.

Henning Rogge
=2D-=20
Diplom-Informatiker Henning Rogge , Fraunhofer-Institut f=FCr
Kommunikation, Informationsverarbeitung und Ergonomie FKIE
Kommunikationssysteme (KOM)
Neuenahrer Stra=DFe 20, 53343 Wachtberg, Germany
Telefon +49 228 9435-263,   Fax +49 228 9435 685
mailto:henning.rogge-FCsFpRLaMoKatNDF+KUbs4QuADTiUCJX@public.gmane.org http://www.fkie.fraunhofer.de
GPG: E1C6 0914 490B 3909 D944 F80D 4487 C67C 55EC CFE0

--nextPart4303306.S5F0AqoMOV
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkte6PMACgkQRIfGfFXsz+C3owCgqAiF1R5lHUH0jHj48EwGUkN4
v6AAn23wy074YEgEveL/oLG8Lj+DGiuj
=+63I
-----END PGP SIGNATURE-----

--nextPart4303306.S5F0AqoMOV--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
