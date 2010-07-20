From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH] net: Add batman-adv meshing protocol
Date: Tue, 20 Jul 2010 20:49:30 +0200
Message-ID: <201007202049.31530.sven.eckelmann@gmx.de>
References: <1279291156-5297-2-git-send-email-sven.eckelmann@gmx.de>
	<201007202023.17883.lindner_marek@yahoo.de>
	<AANLkTim4QSjgC2BbrEJEpefQahbkSgaRPPfJ-N0aPL-E@mail.gmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart12325748.QrMO9QhGRe";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org
To: Abraham Arce <abraham.arce.moreno-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <AANLkTim4QSjgC2BbrEJEpefQahbkSgaRPPfJ-N0aPL-E-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

--nextPart12325748.QrMO9QhGRe
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Abraham Arce wrote:
> Minor comments...
>=20
> 1. Is it ok to have a README in drivers directory? why not moving it
> to Documentation/networking?

Thanks, I will check if Documentation/networking is a better place.

> 2. Compilation error, one extra arguments passed
>=20
> - stats =3D (struct net_device_stats *)dev_get_stats(skb->dev, &temp);
> + stats =3D (struct net_device_stats *)dev_get_stats(skb->dev, &temp);
>=20
>   LD      kernel/built-in.o
> net/batman-adv/hard-interface.c: In function 'batman_skb_recv':
> net/batman-adv/hard-interface.c:482: error: too many arguments to
> function 'dev_get_stats'
> make[2]: *** [net/batman-adv/hard-interface.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> make[1]: *** [net/batman-adv] Error 2
> make: *** [net] Error 2

Do you use linux-next or net-next-2.6? Because this is needed to get it=20
compiled as dev_get_stats was changed some time ago (commit=20
28172739f0a276eb8d6ca917b3974c2edb036da3), but this is not part of 2.6.35.

Best regards,
	Sven

--nextPart12325748.QrMO9QhGRe
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMRe+6AAoJEF2HCgfBJntGWSMQAIE5JUMrH7+EroXGOfZPQ79i
OecNYD/76+dx2MFTh7qc3lBSzFI3Tke86YPaaLyRzJQvI1u82wkCvktrCdJ0hRpS
wXFXNUqXN3SnBhBofaqOiwaCGMxlbFyK+QR2+ldkrzKV3EskSDme7lLqTBGnFumX
P4FuNKBYdK4sI43YifyyKWV587SD5BouAyvygwyssSGk/lRCn0Ain6QUiWmAWYfn
s/Db2UonpRTi9F4BICPTNDpB0/rhDxZL7pJLCKzX9Huupx0PHL3uHjDHLxMQUJAb
OILholTguVGo+BpVXNNrA2dRGFIktZahmh/6QqvfsPcjES4floi6+4AA0QtvZqC2
YIvOz1DAxd+3RPxmrkcPcveqiPIQ8usFYrUGwGiqj4CndjD2jk/POJcL2EP1CLBV
TmlB87q0ZWv5rlT+8P5jgF59Q/CQbYqNkGdVTqp0jMLI8/gdPkh3w5OdkoLsg2qH
MuaruD9e4LJDZomgcVoaGzpE5m0C0DRfkz2H7galcKFPsZKG4wM/RCHmJc6XVrhU
Vh/lnvxS/ZchBV5JlxIh6XSbE3gJN+y2QGDx24NAAwNYr8Ux4wBTeqrNhZum2l/V
NAJMSvnNH/YYG9/J4h9SiryDl+vj/6Hnde6ZsUxRoUu8e0sW3EgDGrpsM07SHOLB
xdaZx9aEEW1qRu+OdguV
=w3l5
-----END PGP SIGNATURE-----

--nextPart12325748.QrMO9QhGRe--
