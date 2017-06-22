From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH rdma-next 13/19] RDMA/netlink: Add netlink device
 definitions to UAPI
Date: Thu, 22 Jun 2017 07:28:27 +0300
Message-ID: <20170622042827.GJ1248@mtr-leonro.local>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-14-leon@kernel.org>
 <20170621161149.GB10200@obsidianresearch.com>
 <748B799B6A00724488C603FD7E5E7EB976FA5C5C@FMSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wHh0aNzodMFDTGdO"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Tung, Chien Tin" <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <748B799B6A00724488C603FD7E5E7EB976FA5C5C-XfjTATA9Em864kNsxIetb7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--wHh0aNzodMFDTGdO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 04:18:54PM +0000, Tung, Chien Tin wrote:
> > From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> > Sent: Wednesday, June 21, 2017 11:12 AM
> > To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Tung,
> > Chien Tin <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>; Steve Wise
> > <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>; Stephen Hemminger
> > <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>; Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>; Ariel Almog
> > <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>; Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>; Leon
> > Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > Subject: Re: [PATCH rdma-next 13/19] RDMA/netlink: Add netlink device
> > definitions to UAPI
> >
> > On Wed, Jun 21, 2017 at 09:05:22AM +0300, Leon Romanovsky wrote:
> > >  	RDMA_NL_IWCM,
> > >  	RDMA_NL_RSVD,
> > >  	RDMA_NL_LS,	/* RDMA Local Services */
> > > +	/*
> > > +	 * RDMA_NL_I40IW not in use and it was added here by mistake,
> > > +	 * but we need to keep it anyway, because it is UAPI and for
> > > +	 * unknown reasons, someone in the field decided to replace "5"
> > > +	 * with this define.
> > > +	 */
> > >  	RDMA_NL_I40IW,
> >
> > Since this doesn't do anything, never did anything, I think you should just
> > delete it. Anything in userspace that refers to this name is unconditionally
> > broken and a compile failure is the better choice.
> >
> > Jason
>
> I agree.  Please delete RDMA_NL_I40IW.

Fixed and Steve's comments too.

Thanks

>
> Chien

--wHh0aNzodMFDTGdO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllLR2sACgkQ5GN7iDZy
WKfDWw//TVKsrX0ITCDRwl6xuIGYASIHC/356qZaGDkbLxNDJEqAzSo/mqH7PNtX
r8v611W1RqkTHt3mh0BQrJJMbmfGT+EiIgu+qZ2LUs6NuJ1IYG3MaMgNvFk3sAun
07ldm6C/6WihJkTorGlERSRDIsp0Ce+DRiWjaPVCEvGcYWRsajMxFHeqf9xyVWiZ
EVimPKDBWyZ9D9i/sr6aEJ9O3K+rNKXeSKcvY48etbiHMt81ADj98wDtEx/f3nwJ
VpQyd/DzIWJmjurt2swuVOLudgwlX7qJLVExNNbHOjOZg/CNG6ghqQOl76UV5Li+
7IHkWFcMNeZ9XCjxJwg+TghJl80xA0HHi41Jh2X/94EX9KP+GQwVhNbEQ0sD5U1p
ZDh7ZgYiGRSmxx01WOrhqM2h+SjY9X6JaePbUALMqlCspIF9DaWPlwo6rSAPfpHh
0pHa2SqdqMIggHBlYBFtycw8gM1F/RWffWj5tVeP3NMSoxyoQi/i/Qb/Hj7NDtBb
D4m0QU3C4kg65dFsYzDkpw9Oy4nQDiCH0jz/83PwAPvUc4UpYHI4zPW9PgQ3Ih8t
0FMNh0y8cmFZ2wF8RHnRB8e/2qvR57owKXcT475THhj42j6nC6BcpCBxSK9j7UW1
8y4a+tfHXWkcDHHuwCFwlSZnOO3ijBelZJbi0LfxiAABuP/nC0k=
=2M2m
-----END PGP SIGNATURE-----

--wHh0aNzodMFDTGdO--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
