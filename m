From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v3 02/11] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Wed, 8 Feb 2017 08:54:37 +0200
Message-ID: <20170208065437.GA6005@mtr-leonro.local>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1486498990-76562-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20170207211901.GB28922@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="N619HKiDy45kBi0v"
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170207211901.GB28922-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--N619HKiDy45kBi0v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 07, 2017 at 02:19:01PM -0700, Jason Gunthorpe wrote:
> On Tue, Feb 07, 2017 at 12:23:01PM -0800, Vishwanathapura, Niranjana wrote:
> > Add rdma netdev interface to ib device structure allowing rdma netdev
> > devices to be allocated by ib clients.
> > Define HFI VNIC interface between hardware independent VNIC
> > functionality and the hardware dependent VNIC functionality.
>
> This commit message could be a bit clearer.
>
> The alloc_rdma_netdev multiplexer is inteded as a new general
> interface and this adds a protocol definition for ethernet VNIC on
> OPA.
>
> The hope is that ipoib can follow the same example and use the same
> alloc_rdma_netdev entry point. Hopefully Mellanox will look at this
> patch as I have talked to them in the past about doing this...

Jason,

We looked on it and it is useless for us, mainly because of the fact
that most  of the work is done in our net part of the driver.

So, as it looks for now, this ULP exercise will be for HFI only.

Thanks

--N619HKiDy45kBi0v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliawKwACgkQ5GN7iDZy
WKeTFRAAhcslIXE7u0hZTLiEG+dJBVM94LuAZ9v3sg+xAVMT7Ty688XJqqn6vfhb
hL9V9wvzCLBf08csVrcERqT3fmwQLznSZ6J4KkB3Kd+j3yzvD9WtHeZMNMPiAlH6
8zdupZFtVLPGN6NgonD7ryZBoDptq4swFcEqXyRJ7go9gQjHW6m1SPx8O1I0zTmt
FxX02ikV2TJ/KodojQEkbmwOWb+N+GyTioNDJYIsvZCDS9koLhacX81ktz/7gRK4
kcZ7yu6lnskzovFiZzfFIGOVdfsc1CC0l81dY/BoZ+fAxIk/t6XT3PMpOuJEWnGA
GBzYxj1dLV0wKn5HZNkb/vP8R/u68JIEJju4SCaU5QD6ZPSu0vHS7nUjrchUYdAG
MQXVT8HfRWuqjle+lFK+ikPvTwGNXzxy5njKxTsV3YgAJ0ZL/5kG3GI96fm3BowL
Sd8Ilq/8YlXRCDhbUjwOeP/ueb3fsXr9H/MqWnaQDs+irDBIcR8P47dlqHOtDHGa
JI8XxtOtgImt1c/y1/oWkspjw1IPI8SZdRWO6rE7H3HVhONkwbyj0MtasGhcUPTH
H580g6Ds7E9aAS+D2t2hfFk621IQlMobdlqxLMF7p8lhA2+OM3tczy60Df0ByJ3+
9t5mFR/odrNPUF1/AG5VXPp8tEADdUPaCSemD8fv0/fCAWmsJYE=
=mrgt
-----END PGP SIGNATURE-----

--N619HKiDy45kBi0v--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
