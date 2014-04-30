From: Jan Moskyto Matejka <mq@suse.cz>
Subject: Re: [PATCH] net: via-rhine: fix compiler warning
Date: Wed, 30 Apr 2014 12:08:42 +0200
Message-ID: <20140430100841.GD24832@moskyto.dyndns.org>
References: <1398792971-10379-1-git-send-email-mq@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6D0F702C5F@AcuExch.aculab.com>
 <CABjd4YzRTPcy1nbhywuNLb0pz4gPVjhzegZJTc_g+_SVc1XJvw@mail.gmail.com>
 <20140430095015.GC24832@moskyto.dyndns.org>
 <063D6719AE5E284EB5DD2968C1650D6D0F702D55@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bajzpZikUji1w+G9"
Cc: Alexey Charkov <alchark@gmail.com>, Roger Luethi <rl@hellgate.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F702D55@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bajzpZikUji1w+G9
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> > Also thanks for suggesting (void*)->(unsigned long), I didn't
> > know that these two are defined to have the same size (in kernel code).
>=20
> The kernel assumes that throughout - the double cast is common.
> The C99 type is uintptr_t - but I don't think that is defined in kernel.
> The only place I know where sizeof (long) !=3D sizeof (void *) is 64bit
> windows. So anyone trying to compile a linux driver to run in the
> windows kernel might have issues (never mind the GPL ones).

My colleague here has just explained me the same. :)

Being a linux-kernel newbie, I'm learning every day. Kernel programming
is more different from userspace than I ever thought. Thank you for your
patience.
--=20
Jan Mat=C4=9Bjka <mq@suse.cz>
SUSE Labs

--bajzpZikUji1w+G9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTYMupAAoJEDFERKcRJ1appn8P/0WMBqWuH3E8xphGaKct9UzD
mNsob4bwdr1VAu3pfzahKr9F7c2RTGp1LwitcUzlC8k7y0AmZW2shpXkYNYTPnag
XzMSUq9WNyMAdP+3aRP0CWPk5HtIM9tJF6x/Uy8KYTXo8940RBXMQ+GgbsVZ+0JE
zs1DbJfvXaAqtIUvBNvhzi9JkQj5dQzjIpsW89sI9ClLqYdszDIoXYBwb3/LNGjf
5B99rTfQ0aLm+wwqCuUQC7yxTYVJR7wABj3JCgsi49aOTC7gva0L0fKo+UdjFduM
ek++KibJBJ4sPUhEpcSgrql0LTaEpFsa+G3uyqCsdMzFg8DdPbiLKI8EXREUokbv
0zCI4LDlwuMyVy2PIqTzRdXuFvpNXAw5sqBFgcWaW2M6m1i/v31b7Ij6z/R5/kTP
za1kyMKEZJ2wmjF++grn78fUD2q4XVCPqWLT99guDxQaT3L+iAbc5Hx1DlwWUHks
73Zya5K6lfqmrVaISposL1FCllXKd5c+mvZugeblyCy7Mefy9XbalKLqnT+NmmN7
uvqOoETWaz3/RNstRzqzvsLFV4r2iE1cCePMtoriCSpjCo83DoZChdYygtN7jsJZ
LI8R+/e7DoKO/WpEG0TaFAFFG6nN1wkXolqNEZOiwJx2n8YmlTh+K5htbs1aQO+z
VHJdWcd0BGcAwJXi0DYk
=gNuT
-----END PGP SIGNATURE-----

--bajzpZikUji1w+G9--
