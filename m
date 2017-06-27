From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 15:18:59 -0700
Message-ID: <20170627151859.524d1079@xeon-e3>
References: <20170626182128.24964-1-leon@kernel.org>
        <20170626182128.24964-4-leon@kernel.org>
        <20170626182924.GB16026@obsidianresearch.com>
        <20170626192103.GH1248@mtr-leonro.local>
        <20170626203610.GB17892@obsidianresearch.com>
        <20170627040604.GI1248@mtr-leonro.local>
        <20170627092129.GR1248@mtr-leonro.local>
        <20170627164150.GA4288@obsidianresearch.com>
        <20170627173301.GS1248@mtr-leonro.local>
        <20170627173735.GA5162@obsidianresearch.com>
        <20170627174615.GV1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/J+z9H3uox8kVBhsBx2358Y/"; protocol="application/pgp-signature"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170627174615.GV1248-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/J+z9H3uox8kVBhsBx2358Y/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 27 Jun 2017 20:46:15 +0300
Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> On Tue, Jun 27, 2017 at 11:37:35AM -0600, Jason Gunthorpe wrote:
> > On Tue, Jun 27, 2017 at 08:33:01PM +0300, Leon Romanovsky wrote:
> > =20
> > > My initial plan was to put all parsers under their respective names, =
in
> > > the similar way as I did for caps: $ rdma dev show mlx5_4 caps =20
> >
> > I think you should have a useful summary display similar to 'ip a' and
> > other commands.
> >
> > guid(s), subnet prefix or default gid for IB, lid/lmc, link state,
> > speed, mtu, pkeys protocol(s) =20
>=20
> It will, but before I would like to see this tool be a part of
> iproute2, so other people will be able to extend it in addition
> to me.
>=20
> Are you fine with the proposed code?
>=20

Output formats need to be nailed down. The output of iproute2 commands is a=
lmost
like an ABI. Users build scripts to parse it (whether that is a great idea =
or not
is debateable, it mostly shows the weakness in programatic API's). Therefor=
e fully
changing output formats in later revisions is likely to get users upset.

The first version doesn't have to be perfect, just close to the overall goal
of what is planned. =20

--Sig_/J+z9H3uox8kVBhsBx2358Y/
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAllS2dMACgkQgKd/YJXN
5H5J/hAArtEg3yhmau9GiMcz460llkvywZas7r5YSMj3rBqXUQu7XcU3xzdNtAVZ
O63XtQBNlejyX//Rggw9kBt0DBGxpw8MGC7C4lpYz7J8gpDdxtIZqzdxkFi9jc13
bXMctdbWms2qm1W5vpBnDDgmuDkT899iLKBVjJ1G26Ohgfm3aaENKB/4X3Hz2IW3
drRuTUjpsHCyQGJDfnSWlIm00w/zPVOrGtZOJ7E3Uozhpg/OVUt4ju2WQnjfeQLx
7ANNubT+lexkF+MiFbPFxjDRKKsbEowM7HPDkEzphhZUd6EnCKd3CWRk4AvFBpqz
D4jGfluaKoknjnkMAP1KFSprPfpCAkpeJ4tCDfS85PAR3lYoLCjHVWumKO6ENXFI
L7pP6yk5iFH7V3Gm4OzRuAGTOU613DT85iC/k0Rh6WbKUneIGAgYqSHvYYDpgm9T
8BOd+LZlpj4tw7NY6/+i3ewCgYLvaOla13Y5xmWmR4Nbgh9Vur+oaTKs9V358THD
SCScKMnzNpkwcQ1Ea4G4wTayTDB3PFAZd7O5+Efaf+MO5CRPTGX4rPPs87O0fskj
3+gzu2u27nvQki5QUNINHZb68o3qkS9K8ythvLpVHKF4cKIUzRz9IGs4YZnbUYX4
Wr6JDIaO/IO/TLXmGzOvhokZIAP9i4+mdT6tYP+CL6AcHojAzHU=
=dWnk
-----END PGP SIGNATURE-----

--Sig_/J+z9H3uox8kVBhsBx2358Y/--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
