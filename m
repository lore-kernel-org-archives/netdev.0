From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH for-next V2 00/11] Mellanox mlx5 core and ODP updates
 2017-01-01
Date: Tue, 24 Jan 2017 15:57:02 -0500
Message-ID: <1485291422.43764.68.camel@redhat.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com>
         <20170102.155341.1496970446718890403.davem@davemloft.net>
         <CALzJLG9ZBRMOVqFsTypCLV6Rrek8a9g43z0spvVKeku6WdWCTA@mail.gmail.com>
         <20170103072344.GF12077@mtr-leonro.local>
         <1485286799.43764.49.camel@redhat.com>
         <20170124195820.GL6005@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-SFTmFs7Oyaxsvd0T3IlB"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, ilyal@mellanox.com,
        artemyko@mellanox.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51634 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750725AbdAXU5E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 15:57:04 -0500
In-Reply-To: <20170124195820.GL6005@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SFTmFs7Oyaxsvd0T3IlB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-01-24 at 21:58 +0200, Leon Romanovsky wrote:
> On Tue, Jan 24, 2017 at 02:39:59PM -0500, Doug Ledford wrote:
> >=20
> > On Tue, 2017-01-03 at 09:23 +0200, Leon Romanovsky wrote:
> > >=20
> > > On Tue, Jan 03, 2017 at 01:30:16AM +0200, Saeed Mahameed wrote:
> > > >=20
> > > >=20
> > > > On Mon, Jan 2, 2017 at 10:53 PM, David Miller <davem@davemloft.
> > > > net>
> > > > wrote:
> > > > >=20
> > > > >=20
> > > > > From: Saeed Mahameed <saeedm@mellanox.com>
> > > > > Date: Mon,=C2=A0=C2=A02 Jan 2017 11:37:37 +0200
> > > > >=20
> > > > > >=20
> > > > > >=20
> > > > > > The following eleven patches mainly come from Artemy
> > > > > > Kovalyov
> > > > > > who expanded mlx5 on-demand-paging (ODP) support. In
> > > > > > addition
> > > > > > there are three cleanup patches which don't change any
> > > > > > functionality,
> > > > > > but are needed to align codebase prior accepting other
> > > > > > patches.
> > > > >=20
> > > > > Series applied to net-next, thanks.
> > > >=20
> > > > Whoops,
> > > >=20
> > > > This series was meant as a pull request, you can blame it on me
> > > > I
> > > > kinda messed up the V2 title.
> > > > Doug will have to pull same patches later, will this produce a
> > > > conflict on merge window ?
> > >=20
> > > Yes, but it can be easily avoided.
> > >=20
> > > Doug,
> > >=20
> > > We have another pull request to send and we will base its code on
> > > the
> > > Dave's tree instead of Linus's rc tag. In such way, you will have
> > > the
> > > same commits as Dave and won't have merge failures.
> > >=20
> > > Please don't apply manually this specific patchset.
> > >=20
> > > Sorry for the inconvenience.
> >=20
> > Hi Leon and Saeed,
> >=20
> > As I understand it, Dave took this series, but I have not. =C2=A0You
> > were
> > going to base another pull request on top of this so I could get
> > both.
>=20
> We did it, ODP was our first pull request and 4K UAR was second one.
> http://marc.info/?l=3Dlinux-rdma&m=3D148398855416090&w=3D2
> Dave pulled this tag:
> https://git.kernel.org/cgit/linux/kernel/git/mellanox/linux.git/tag/?
> h=3Dmlx5-4kuar-for-4.11
>=20
> Since 4K UAR tag was based on ODP, by pulling mlx5-4kuar-for-4.11 tag
> you
> will get ODP too.

OK, I've verified that I have it all, thanks.

> >=20
> > =C2=A0However, I believe that was the attempt to reorg the driver pull
> > request, which David NAKed. =C2=A0
>=20
> It was our third pull request
> http://marc.info/?l=3Dlinux-rdma&m=3D148424983101796&w=3D2
> https://git.kernel.org/cgit/linux/kernel/git/mellanox/linux.git/tag/?
> h=3Dmlx5-dir-layout-reorg
>=20
> >=20
> > That means I have not picked this up. =C2=A0Are
> > all of the other for-next patches you posted against the RDMA list
> > going to go in cleanly without this series, or should I expect
> > conflicts between Dave's tree and my own?
>=20
> All patches sent by me are based on mlx5-4kuar-for-4.11 tag which
> exists in Dave's tree and everything will apply cleanly on your
> k.o/for-4.11 branch and won't have merge conflicts between your tree
> and
> Dave's net-next tree.
>=20
> For you convenience, my submission queue can be found at:
> https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/
> ?h=3Drdma-next
>=20
> Thanks
>=20
> >=20
> >=20
> > --
> > Doug Ledford <dledford@redhat.com>
> > =C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
> > =C2=A0 =C2=A0
> > Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57
> > 2FDD
>=20
>=20
--=20
Doug Ledford <dledford@redhat.com>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-SFTmFs7Oyaxsvd0T3IlB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYh7+eAAoJELgmozMOVy/duWkP/1B1IDFMexzxuA9JTRjvBNlV
hQXvr+8DPftVki+bBYsN2eR8Jy4aGgSVCDtm8FFrK/pW6rgKD+A9+C3cmdu+0wMg
Z/0D587X7fDgOMwRCmkeaERkSFufWeiCR6Hu60ndNdvJ0RTt111fN0ySI5LE/7g8
kzgrtnGl0btPssrnmMU55IcfBkKfc/052ow/lXLRBhsk8N8x7G9FNNc84wQmt4be
dFwoCckt6dcW6RtA13j32ad2WtnYTrs31gAL8ybEi6N/nFqsIsjnhBu9ybiTVfen
mrdVrwiu1/0CASB625xrJTqJJKR8iCWrNYFajCfKycza5utA3cEuXkxCdAh4fgCg
05tcaY17Uqmi1OveAEP5f5SyboG99vhAFQ/Tc3O8OvBM5FSYrFkwK/+RYA0LjvBw
FM6sVIuB/g8WbKR3uCnxSPChE5D6Eh9T+nSUbPD4T2TlJ4yz7WykqG430ZSMrXcx
Nmujd5TMz93gpkdAC8B4m7cJNegjK/UPU4dHkQ6sUxMjS4RhnXibr7beshs2fcZz
WK0qg9nLZP8mnr9mqlR/CtxusCU0Zb1DBjJW98g8JMrC5W6/LSIHW4RVxVtolZq4
7Z7FY9XTlyWykQDcY8l8nfwi2/PEAkoMdBSkkmpUIadvcyxAVhpmfi+0ZxWkZykZ
xdZHQv0LDYQVDsLr3ZAN
=uUpF
-----END PGP SIGNATURE-----

--=-SFTmFs7Oyaxsvd0T3IlB--
