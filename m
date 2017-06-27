From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 15:16:03 -0700
Message-ID: <20170627151603.509af242@xeon-e3>
References: <20170626182128.24964-1-leon@kernel.org>
        <20170626182128.24964-4-leon@kernel.org>
        <20170626182924.GB16026@obsidianresearch.com>
        <20170626192103.GH1248@mtr-leonro.local>
        <20170626203610.GB17892@obsidianresearch.com>
        <20170627040604.GI1248@mtr-leonro.local>
        <20170627092129.GR1248@mtr-leonro.local>
        <20170627164150.GA4288@obsidianresearch.com>
        <20170627173301.GS1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/+r6hNiYMvrohzCmdGvp0JKa"; protocol="application/pgp-signature"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170627173301.GS1248-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/+r6hNiYMvrohzCmdGvp0JKa
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 27 Jun 2017 20:33:01 +0300
Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> On Tue, Jun 27, 2017 at 10:41:50AM -0600, Jason Gunthorpe wrote:
> > On Tue, Jun 27, 2017 at 12:21:29PM +0300, Leon Romanovsky wrote: =20
> > > > What will be the output of such command?
> > > >  $ rdma dev show mlx5_4 =20
> > >
> > > ip-like style:
> > >
> > > $ rdma dev show mlx5_4
> > > 5: mlx5_4:
> > >     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE=
_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC=
, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_=
CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
> > > $ rdma link show mlx5_3
> > > 4/1: mlx5_3/1:
> > >     caps: <CM, IP_BASED_GIDS> =20
> >
> > I think that is better, maybe it should only show under some kind of
> > verbose mode, I don't know, it depends what other stuff ends up being
> > displayed..
> >
> > Are you going to dump the gid table and pkey table too in one of these =
commands? =20
>=20
> My initial plan was to put all parsers under their respective names, in
> the similar way as I did for caps: $ rdma dev show mlx5_4 caps
>=20
> So for large dumps, I'm going to use that technique again and maybe print=
 summary as a default.
> For example, for gids, we can print utilization as a summary while whole
> table if someone really wants it: $ rdma link show mlx5_4/1 gids <index>
>=20
> Something like that.
>=20
> Thanks
>=20
> >
> > Jason =20

Agree with discussion so far.

For iproute2 style commands, the show and set commands need to have similar=
 arguments.
Ideally, everything after the colon in the show would be parameters to set =
command.

Please consider having a concise form for normal users and a detail form (w=
ith -d) for=20
configuration and setup cases. The caps should not need to be displayed in =
normal show
output.

--Sig_/+r6hNiYMvrohzCmdGvp0JKa
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAllS2SMACgkQgKd/YJXN
5H6kBQ/8CfgU7wcXQBh+2nN0gTiEDURx+BIGQrn924ryf7edn5v/LJxW01yAlJLi
jYCF0Ne2A0fGj5r9BwodIsJULdCvxRh3YNwsdfoo8yMVwEEzYPS76VCS09Ak/RSO
4xQ0BHbaVXv257PkRLi4apKMH/KlH8EOZB+lSLSaGQ6AjvsqEhVIWTXdo36x5qmd
IfUVvUUIxKsYnB9TZfo7rBURZBHA9z8pods+OFckY7b+7LaPBae7+wJ7xAMKhjw+
GW7i5PBkOMITPIk09PxaPI3M2djENDX6MEk2Zu5O2Y0Xhfbrkpn5ifGU9tdSMhDv
jHYFGWrzwhdNAnmSDOz2rHkyQvO/ZleCc38e5iztRmgeOh4zQ92pJnG1uwjNDgnx
+XngCobxz6I30UIXBpjRWQRSASy5gaN8Txl2+IF9qjoQH7kgm3FPH/5v6l4BRbsw
mniDbt9yAMcBzutwt0zDaZhLRiwXgCW66Llrph8V3OWUjlzWDeh84rtDJMA2mAXZ
MXbNb72VVgJd9Te8e54tahlz+Y78PdsOnFIcvTv1oFmFdVRf5M44GL+Q0LwhzEtM
4XX2cRSP6goILWo8c6M+0ATJZ3pER/+PG3QaYct/iyURnsYYRby9aNQILY+GceCp
xI6oG/bv5hMet3e4B/8+Bln6vD1yiMigQWe9o3szZLce1Kk9Nbk=
=zMMW
-----END PGP SIGNATURE-----

--Sig_/+r6hNiYMvrohzCmdGvp0JKa--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
