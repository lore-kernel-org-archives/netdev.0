From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 17 Sep 2014 12:18:08 +1000
Message-ID: <20140917121808.27977073@canb.auug.org.au>
References: <20140917110454.399a7841@canb.auug.org.au>
	<20140916.214859.1906368469534009374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/C1dOj0=f.Gtgr.IlFc622L2"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, anish@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140916.214859.1906368469534009374.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/C1dOj0=f.Gtgr.IlFc622L2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Tue, 16 Sep 2014 21:48:59 -0400 (EDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 17 Sep 2014 11:04:54 +1000
>=20
> > This is a bit different to yesterday's failure but I assume it is still
> > related to commit 5d6be6a5d486 ("scsi_netlink : Make SCSI_NETLINK
> > dependent on NET instead of selecting NET").
> >=20
> > I used the net tree from next-20140915 again today.
>=20
> Should be fixed by:
>=20
> commit 6a38792ca8a5da28f65dc42eeb73d9a431f8d0fd
> Author: Randy Dunlap <rdunlap@infradead.org>
> Date:   Tue Sep 16 13:47:41 2014 -0700
>=20
>     scsi: use 'depends' instead of 'select' for SCSI_FC_ATTRS
>    =20
>     There are other kconfig symbols which use SCSI_FC_ATTRS.
>     In order to maintain sanity and prevent kconfig warnings, change
>     all of these from using 'select' to using 'depends on' so that
>     proper symbol dependencies will be honored and circular depends
>     problems will be avoided.
>     This fixes kconfig warnings and build errors:

OK, thanks.  That was not in the net tree I fetched this morning, so
should be good tomorrow.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/C1dOj0=f.Gtgr.IlFc622L2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUGO9kAAoJEMDTa8Ir7ZwV0D4P/2TaL3IDRucJ9wG0lmpxJxXu
Mn23DMYSmVqfWBC/3SAa2had30q0OozZEyLGLRtelKwtikX2dCvBtE5cX+winX7T
hcRGqn1WOoZlk4xzGOmsJT9BiDiR5ZkOyWt4KCsJx7HhlwlWDok/EdLi0LguzS63
ygDxDQdRa3k83XxKghPWhbdPIovuQ9aD9pFq6JPKLvSgrJcKsbcgq+mRS6F1UxmD
njVq+LWSmIJgUzbSMheiRExBfRGuvm14OoinTfzkttAgdAQKZasOtCa5CtSvnhoN
JdjFNnQJBeYOQt3NV50+jZHlRG+Rp4TGquBG28I7Mlmzf1wmJBfAyL2nh+IEqZER
ZMbUwAmnRkpvZQOKH9TFGObP00z6pprSUwYOV2K10ifKkn3Zwa6axF/TA5CJWQG0
9FztZqfrCE3zXv62a8yhvkbzAgJJlZ7pfawU5gNzwp8yhCf5GCc/3y3SKTJrLC1t
fxlYdFmyO2ve9sM8j07iTOauGStVegN6VYtdm5Sod5nVfkCVs4MJrocnJgzYhGmB
p9XQBtEvzj/c334/k1X44aEI7G3FINsef/WJmbRWUQHG2/r5Ud6lK2ITGpKSnmuz
KQyEvAjfx2nNGVAWCRjVd0sL40YRIziLhW4NF6kcyQZMNBnC1KKUoJVASR3sxxAq
EPlIIOUWX4yJN9fxBGFP
=Jgf3
-----END PGP SIGNATURE-----

--Sig_/C1dOj0=f.Gtgr.IlFc622L2--
