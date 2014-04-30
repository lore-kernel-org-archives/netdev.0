From: Jan Moskyto Matejka <mq@suse.cz>
Subject: Re: [PATCH] net: via-rhine: fix compiler warning
Date: Wed, 30 Apr 2014 11:50:15 +0200
Message-ID: <20140430095015.GC24832@moskyto.dyndns.org>
References: <1398792971-10379-1-git-send-email-mq@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6D0F702C5F@AcuExch.aculab.com>
 <CABjd4YzRTPcy1nbhywuNLb0pz4gPVjhzegZJTc_g+_SVc1XJvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="c3bfwLpm8qysLVxt"
Cc: David Laight <David.Laight@aculab.com>,
	Roger Luethi <rl@hellgate.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey Charkov <alchark@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABjd4YzRTPcy1nbhywuNLb0pz4gPVjhzegZJTc_g+_SVc1XJvw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--c3bfwLpm8qysLVxt
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> > So why not just:
> >         revision =3D (unsigned long)match->data;
> > and add a comment that the 0x84 is the revision - #define ??
>=20
> There is no particular reason why it should be u32 now - this is a
> leftover from the previous iteration of code where revision was a
> separate property in DT (sized u32). It actually mirrors the
> respective field in struct pci_dev, which is u8 - don't see any issue
> defining it as unsigned long (and also changing the definition in
> struct rhine_private).
>=20
> The comment that it's the revision is right above the match table (cut
> off in the patch) :)
>=20
> Jan, would you prefer to adjust your patch, or shall I send another
> one to change rp->revision and friends to unsigned long?

I prefer you to make another patch, you obviously know more about this
driver. Also thanks for suggesting (void*)->(unsigned long), I didn't
know that these two are defined to have the same size (in kernel code).
--=20
Jan Mat=C4=9Bjka <mq@suse.cz>
SUSE Labs

--c3bfwLpm8qysLVxt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTYMdWAAoJEDFERKcRJ1ap67oP/jJyRjpSmZCBMJQ0PCTuqKHB
X+g4xQDJ3Jz1Q9ixUrDWPchyGOTpJZ2D/XT0ATLFMhfZKblWBFd9hQ0hNIsqrRMs
sSBgK0elQX4hwmQzUCl2K3Ta6KMUQSY9WDLVINjmPl4SfWtKNH58DWpFMetJhUF7
F0NQ2G7BQGw/s/5dHwiKZCqTSL64anhQGW2hgQbncsy7ZiiUh7viUrMNnGXMaWX7
wa9fWTf+oN96RhXMvcF3KGC5gvzfSM/uxCyK88pueCZfW38ZRs/f8EMxnL0PrcCE
XxJLf6S6cIwC6YyNd4aR95eUq37Iy6R7tZNExCNyxAoDuKwygBZt2zGrQHwENZiA
brOoFZAnyHRXs4rkdZuTX6qru148C3tgvRwh9coH9X0Xa+GZmtXItOdb9f01Ufs+
4sGF+KFg9/f4C6+ZuNHidIe5Vm2l1Q9FpeftfpKCCIROkqj18pGjAWaXgKuni+rl
4/9VEO7Bc0k8yF5XKw92YU3XgnmNkhj12obgFDJP199+pN4tcTIQ93oljssNHBt/
AuY4lvfZEhTTqIl6k1HCn3GJABKZwFrQVfSgOjeZpm2zfeDdxKyNRxC3GCLD5vPv
FZQQMkOZXhfgCOkIKIj/pMSjLbANIEQQ7ARhVVqsboxrKh5FMGgA7hJD1JT846nD
VNarXuBXP7zzRYQTtLj9
=OOOO
-----END PGP SIGNATURE-----

--c3bfwLpm8qysLVxt--
