From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 12:21:29 +0300
Message-ID: <20170627092129.GR1248@mtr-leonro.local>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="AoBLyXwWXtFbU0pZ"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170627040604.GI1248-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--AoBLyXwWXtFbU0pZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 27, 2017 at 07:06:04AM +0300, Leon Romanovsky wrote:
> On Mon, Jun 26, 2017 at 02:36:10PM -0600, Jason Gunthorpe wrote:
> > On Mon, Jun 26, 2017 at 10:21:03PM +0300, Leon Romanovsky wrote:
> > > On Mon, Jun 26, 2017 at 12:29:24PM -0600, Jason Gunthorpe wrote:
> > > > On Mon, Jun 26, 2017 at 09:21:26PM +0300, Leon Romanovsky wrote:
> > > > > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > > >
> > > > > Add parsing interface for the device capability flags
> > > > >
> > > > > $ rdma dev show
> > > > > 1: mlx5_0: caps 0x1257e1c26
> > > >
> > > > This seems very un ip-like. I wouldn't show an undecoded hex value
> > > > like that, it isn't really useful.
> > >
> > > It is first supported field, after new fields will be added, we will
> > > have very similar to ip interface.
> > >
> > > 1: mlx5_0: caps 0x1257e1c2 key_1 val_1 key_2 val_2 ....
> > >
> > > The values are presented as is can be usable as an input for different scripts.
> >
> > I still wouldn't show an undecoded hex value.. It isn't useful.
> >
> > > > > $ rdma dev show mlx5_4 caps
> > > > > 5: mlx5_4: caps 0x1257e1c26
> > > > > Bit	Description
> > > > >  01	DEVICE_BAD_PKEY_CNTR
> > > > >  02	DEVICE_BAD_QKEY_CNTR
> > > >
> > > > This table also seems un ip-like, the usual format is a list of words,
> > > > I think.
> > >
> > > It is true for key<->value data, but it is less obvious for bit
> > > parsing.
> >
> > Several of the word decodes are from bit fields..
> >
> > > Internally, I tried to present them as list and it was ugly like hell
> > > without any chance (without extra parsing) to actual see if specific
> > > capability is present or no.
> >
> > lspci seems to have no problem being readable while doing this..
>
> No problem,
> If i understand you correctly, you are suggesting to drop parsing of
> "caps" as a separate command and embed it into general show <devname>.
>
> Can you help me and give an example of how would you present those caps?
> What will be the output of such command?
>  $ rdma dev show mlx5_4

ip-like style:

$ rdma dev show mlx5_4
5: mlx5_4:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
$ rdma link show mlx5_3
4/1: mlx5_3/1:
    caps: <CM, IP_BASED_GIDS>

Thanks

>
>  Thanks
>
> >
> > Jason



--AoBLyXwWXtFbU0pZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllSI5kACgkQ5GN7iDZy
WKezPhAAhvMaTTxdHMmUle86E//sNMbJ+u8zmflDd8h5i/vQN0xlgbkG6KRg+u7i
nYLORg2Iu/ydqta3ToapYudv8d/34HusRaL0DM2tZroQ9fSjh7tIbUKcPVE2+TA5
LrMfa6VYArnGMpfHUnKLSwODy13i7bCpwGXhE1aUu0S/+7ix6bGFeCcnSGYA65EP
45sa28RS+hg0MJuO6lqcgxUhGJw7OhTHBvU0Xr3yTv7Z3Ojgw3S1oKtvVnOwdRO1
/qFUNRxVRDdz/TyoGJGn57fyHyP2aZmHdxwdPKO7kSUOxzq/9/lwYD9P3WBBwBpR
hxfypTd4TaJZ5p+9ckDPRsDRPHWXuTMSpQ1JWDGafVmZLYwYzI6vBAn/3fFkCE6c
z61FqtKZbCxZX4ewlkyGOyJbPZD6UfMY4he3MaguOVy9xDRQ/6h+Zrlu42wbx0DN
zdppyjOz6UioRd+jc2fHVXeLSt8l+pxC8RoUJnWAbdcLgKusQCiqipnMA25leIxY
zz3vmMz1CKaCUKQDDpgzHMOV19fQogG41z8uEaAoCgePz2/X6OKFFLXZkRldv0/E
NAftzDTkSzlVS8G0n8yt04NiqqF+4IXHq8rHJ7bJ/KQel6OM3vFJQBPMT1mHK3Lt
QZ25i1tDQKd8TNBHPd/ornVN4gMwj1+cq05YyqBE6TSd4PypJm8=
=3nCB
-----END PGP SIGNATURE-----

--AoBLyXwWXtFbU0pZ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
