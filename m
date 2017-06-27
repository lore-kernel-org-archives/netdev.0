From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 07:06:04 +0300
Message-ID: <20170627040604.GI1248@mtr-leonro.local>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="qih7n4MdZQ4fb9uN"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170626203610.GB17892-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--qih7n4MdZQ4fb9uN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 26, 2017 at 02:36:10PM -0600, Jason Gunthorpe wrote:
> On Mon, Jun 26, 2017 at 10:21:03PM +0300, Leon Romanovsky wrote:
> > On Mon, Jun 26, 2017 at 12:29:24PM -0600, Jason Gunthorpe wrote:
> > > On Mon, Jun 26, 2017 at 09:21:26PM +0300, Leon Romanovsky wrote:
> > > > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > >
> > > > Add parsing interface for the device capability flags
> > > >
> > > > $ rdma dev show
> > > > 1: mlx5_0: caps 0x1257e1c26
> > >
> > > This seems very un ip-like. I wouldn't show an undecoded hex value
> > > like that, it isn't really useful.
> >
> > It is first supported field, after new fields will be added, we will
> > have very similar to ip interface.
> >
> > 1: mlx5_0: caps 0x1257e1c2 key_1 val_1 key_2 val_2 ....
> >
> > The values are presented as is can be usable as an input for different scripts.
>
> I still wouldn't show an undecoded hex value.. It isn't useful.
>
> > > > $ rdma dev show mlx5_4 caps
> > > > 5: mlx5_4: caps 0x1257e1c26
> > > > Bit	Description
> > > >  01	DEVICE_BAD_PKEY_CNTR
> > > >  02	DEVICE_BAD_QKEY_CNTR
> > >
> > > This table also seems un ip-like, the usual format is a list of words,
> > > I think.
> >
> > It is true for key<->value data, but it is less obvious for bit
> > parsing.
>
> Several of the word decodes are from bit fields..
>
> > Internally, I tried to present them as list and it was ugly like hell
> > without any chance (without extra parsing) to actual see if specific
> > capability is present or no.
>
> lspci seems to have no problem being readable while doing this..

No problem,
If i understand you correctly, you are suggesting to drop parsing of
"caps" as a separate command and embed it into general show <devname>.

Can you help me and give an example of how would you present those caps?
What will be the output of such command?
 $ rdma dev show mlx5_4

 Thanks

>
> Jason

--qih7n4MdZQ4fb9uN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllR2asACgkQ5GN7iDZy
WKemBg/+LFFQJs5UsNfjdLnnJ+YAcRBxApZwXG4z1uRjH/NNuakxMdzoEiLDGNKV
/s1782zvsEvOtAH5rXTLJB9kAN4i6Bk7r9FVq7t2pvXb0hDQPc/l8GmasCgf6kwI
dBvFlvcKdBBlPeXDcl1I2pqreXgEKV+I36zQw8NnGwehLwGGRQZ62SIQbL0/D61D
pPEYOachC14aIEyovz+U4SDWEi6eFGyOGAb1hiZKiG8W0MkrRVBNod7gLP5267HG
zwjr1BG347R99nVGcAkANjWxrb6Z+iN+Zd8UmXcCJIxN+HRPU5DNV1TAEF5T/jjI
O/aY2NspZJrafv2xyPTSgUc1zOS8lUDsyVFaL8f7nfpCWStp2xO0Bz0CbL6NlOwa
9pY3M1ys0yzjVnpUDbotqj15qylTntnh5+OyC7+L3IJ24BrUhtwx0E0KDpLaesUj
MehTvA+alsKFSRoHNB91KyYZe7A+9oD1A7YWBs6lTFvjOdK7EC7kwqRVAxtPWT7g
dnk2gi0G/sBszu/+mrgYKOybjgZrIYoBs3LrdU3D9t5hzbRIGvRLk5rMymgwh0mR
FS/V9vh/0R2BZBXcqvE654M6l9YDLs40uW5UkETjghZDM9QMKP0g+/+8UJXG5ONx
OvC37dWk6MZimuLmEH3iQo7iwh7KJXFLtS/7bhGF9/ZuQWNsMxg=
=i4qx
-----END PGP SIGNATURE-----

--qih7n4MdZQ4fb9uN--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
