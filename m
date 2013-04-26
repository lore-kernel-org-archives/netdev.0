From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: linux-next: manual merge of the net-next tree with the
 infiniband tree
Date: Fri, 26 Apr 2013 13:50:20 +1000
Message-ID: <20130426135020.1f504f56b6c3412201f4fb9d@canb.auug.org.au>
References: <20130418131843.bfeb6b1ad5fba1b0f706076e@canb.auug.org.au>
	<20130424175304.GA701@oc0268524204.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__26_Apr_2013_13_50_20_+1000_zlQAPrdRZwOHWPGC"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130424175304.GA701-kqNz3JI7O+u3AZEqMmYM8VaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__26_Apr_2013_13_50_20_+1000_zlQAPrdRZwOHWPGC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Cascardo,

On Wed, 24 Apr 2013 14:53:04 -0300 Thadeu Lima de Souza Cascardo <cascardo@=
linux.vnet.ibm.com> wrote:
>
> On Thu, Apr 18, 2013 at 01:18:43PM +1000, Stephen Rothwell wrote:
> >=20
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/infiniband/hw/cxgb4/qp.c between commit 5b0c275926b8
> > ("RDMA/cxgb4: Fix SQ allocation when on-chip SQ is disabled") from the
> > infiniband tree and commit 9919d5bd01b9 ("RDMA/cxgb4: Fix onchip queue
> > support for T5") from the net-next tree.
> >=20
> > I think that they are 2 different fixes for the same problem, so I just
> > used the net-next version and can carry the fix as necessary (no action
> > is required).
>=20
> Commit 5b0c275926b8 also keeps the intention of the original patch which
> broke it, which was to return an error code, in case the allocation fails.
> Commit 9919d5bd01b9 fix will return 0 in case the allocation fails.
>=20
> We should keep the other fix or fix the code again to return the proper
> error code.

OK, so today I switched the conflict fix to use the version from the
infiniband tree.

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

--Signature=_Fri__26_Apr_2013_13_50_20_+1000_zlQAPrdRZwOHWPGC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRefl8AAoJEECxmPOUX5FElWYP/0gd5bzIlZAhq1HBEAp4Sv6n
7OfvDC/0brGRrfRPg7flwVEuzftUmTkFjtQHmntYvw+omke6/Bc55z9u13Z0CnFu
QYJv2YYgjKiZ4MtXiyZ7yYg/Y4ppIXMalbzTZ3VTx4InXkoDTZUjBd3wghHrD+lP
eghwlvH2ar2Z6XyKP300fbOGWJLIk+klC8Cr42W/s6DxMgBVUa42vovLo/2XDuNT
YEoOEGOiEcDHB5sOaFKoKTFQJoxR+J/bbpDDRzfUVMubXiZEvtxmQs1FMDpCBkBD
o3FGlCYwXqb/Lmxh1lzoSQb538vQrg4XfyDUGU/1eRuRy0aBYIYaq5jVLHfsmNvt
eHQf9TOUEV/mtJmUyF546UUEp/TNafbVqWdLIHxw2irr/oPC04oCJTx2Sy+lfgju
k5CRXzZB55NY6+G9qzCUn7UnrFz8Tm0cwHBm38f84LE2U+HuYP15KsurDJfAXNb2
VCeMk7tSPbldFsSeBov5NUpPz0qGHsw13hgBFySdhY9vmsAAMIPR88dudwyiVLWS
0QENerBIbcNqDevZnZaQK6l1B8avOzlJOjwzJaQP7YolDhkxxlYdJ15kcHUEtBNY
XCc3mYlbz//kUnQsQjSWw1MM3AE8STMCjSJbAkWEIWtUqMANaS5cuSVsNt03qMjy
SgivZhqJsoMhC/1/HCBj
=25rY
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Apr_2013_13_50_20_+1000_zlQAPrdRZwOHWPGC--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
