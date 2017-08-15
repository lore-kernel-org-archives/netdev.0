From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 19:47:20 +0300
Message-ID: <20170815164720.GV24282@mtr-leonro.local>
References: <20170815130020.29509-1-leonro@mellanox.com>
 <20170815130020.29509-3-leonro@mellanox.com>
 <20170815091205.2c39ea91@xeon-e3>
 <063D6719AE5E284EB5DD2968C1650D6DD005604E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="v6ieFHm5OYqyo94Y"
Cc: 'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005604E-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--v6ieFHm5OYqyo94Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 04:23:11PM +0000, David Laight wrote:
> From: Stephen Hemminger
> > Sent: 15 August 2017 17:12
> > On Tue, 15 Aug 2017 16:00:15 +0300
> > Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> >
> > > +
> > > +static const char *dev_caps_to_str(uint32_t idx)
> > > +{
> > > +	uint64_t cap = 1 << idx;
> > > +
> > > +	switch (cap) {
> > > +	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
> > > +	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
> ...
> > > +	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
> > > +	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
> > > +	default: return "UNKNOWN";
> > > +	}
> >
> > Could this be a table in future versions?
>
> Potentially you could define the constants using some pre-processor
> 'magic' that would create the table for you.
> Something like (but not compiled):
>
> #define RDMA_DEV_FLAGS(x) \
> 	x(RESIZE_MAX_WR, 0) \
> 	x(BAD_PKEY_CNTR, 1) \
> (continue for all the bits)
>
> #define RDMA_DEV_ENUM(name, bit_no) RDMA_DEV_##name = BIT(bit_no),
> enum {RDMA_DEV_FLAGS(RDMA_DEV_ENUM)};
> #undef RDMA_DEV_ENUM
>
> #define RDMA_DEV_NAMES(name, bit_no) [bit_no] = #name,
> static const char rdma_dev_names[] = {RDMA_DEV_FLAGS(RDMA_DEV_NAMES)};
>

David,

How should I handle "uknown" fields without names?

Thanks

> 	David
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--v6ieFHm5OYqyo94Y
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmTJZcACgkQ5GN7iDZy
WKcYTw/8COCK6vkmbjhp2Rh+sv5qPg57ygeZqG9W+k8ASCFys9208TKpWJ0yA72F
dN7JGpMzQBd1BNMhG2F/ouYMsy0/r0e4kYgFUMqaGPB24SevjbpRbIAVKwjJ4tCu
qTcUruvzzZG79uF+0avw2l71xkwQNG+7un2VSkz9WTjqaWafCKTHCNAKQVCLuJd2
gWWP7WupR2Mz0AGxkIOZLSkpsnmt8E15+ryt1xjMYcX9wzpnN0Vo5rMeXspDYRvf
qub+F2BLYpGDprUIzgH/WG2zdpPngfWGjuN/ijKd49T48K46OBuLd2D83JqWSHM4
nj+sWoGx9c5T8cutRNHlLffHC5QoQO685sM5g4RTExY8ZCmD/te2A3y5nf5RrGE8
STY5AhKrdlx8uiycqaFzEpo7oPFLxrOXCQue4UulieeScC+en0gUGaFL7aMeOlsy
kjdnKCyNoyS9jQPr/dyirmH3iVIx+tYXJX+0IJT+1FnrOEEcEfTNcLCaYShqfUXG
dpGjH1OTMbgn3IjNbCVyNOCFZBy4aUhR78NQsgmEEpj8HmLgVTasP4fy6KEKvmTb
Vqbid5T307g0Zoc2Wne5AU/St7ZhzaiGEWqHDlKWiFuI6eff+MOjIJP2x6rREOpe
b9U2n6m0cgL2TFnxRrL1tAT88CemIDNDq+HhWTvwo6riNOfdtA0=
=Ub1k
-----END PGP SIGNATURE-----

--v6ieFHm5OYqyo94Y--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
