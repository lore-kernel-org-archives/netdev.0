From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC v1 for accelerated IPoIB 04/25] IB/verb: Add ipoib_options
 struct and API
Date: Wed, 15 Mar 2017 08:30:43 +0200
Message-ID: <20170315063043.GC2079@mtr-leonro.local>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
 <1489429896-10781-5-git-send-email-erezsh@mellanox.com>
 <20170313200136.GA2738@obsidianresearch.com>
 <20170314070109.GD79937@knc-06.sc.intel.com>
 <20170314161149.GA15752@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="6zn93sY2JrH9m7VZ"
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Erez Shitrit" <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170314161149.GA15752-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--6zn93sY2JrH9m7VZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 14, 2017 at 10:11:49AM -0600, Jason Gunthorpe wrote:
> On Tue, Mar 14, 2017 at 12:01:09AM -0700, Vishwanathapura, Niranjana wrote:
> > On Mon, Mar 13, 2017 at 02:01:36PM -0600, Jason Gunthorpe wrote:
> > >>+	/* multicast */
> > >>+	int (*attach_mcast)(struct net_device *dev, struct ib_device *hca,
> > >>+			    union ib_gid *gid, u16 lid, int set_qkey);
> > >>+	int (*detach_mcast)(struct net_device *dev, struct ib_device *hca,
> > >>+			    union ib_gid *gid, u16 lid);
> > >
> > >It would make more sense to store the struct ib_device pointer in the
> > >struct rdma_netdev.
> > >
> >
> > Agree that it shouldn't be a function parameters.
> > For opa_vnic, I found it convenient to store ib_device pointer in client and
> > device private structures as those will be available in most places anyhow.
>
> If vnic uses it too, then lets add the ib_device and port num to
> rdma_netdev itself?

Agree, at the end this rdma_netdev is intended for the drivers/infiniband
and it is better to have this binding (rdma_netdev and ib_device) as early as possible.

Thanks

>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--6zn93sY2JrH9m7VZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljI35MACgkQ5GN7iDZy
WKdJog//VO7d2e5IjoQIDKLpRIPlbkrbjaJngFR7qridkcyLZgDrjndyAzZ0lLdA
80CiWRqbfqLJpwcgZbFmBlu2A5dFqf7ZHAV8OMcHQL46ZQ0+gzzcQ/2RAMldPH43
zUq2cxZCOIbQEIMyspaaWO6AkGdSSN8916yjXyUm5sbNgHtu0wk2f/TFOxbpszjG
Z/J/G6Cs4V9V5r/8YqG4Aos5tSXa1hxZkZDyjwecBkTWzM8qcaJJRL5sQVTSWiLc
WiW9uSVmmR7gdYGOZtBNFfSdDmolO0untUTt5uKZ4E7GshJrNHDM9SSYu7UZAQg7
9oZK6lBi7Z6dYdhzJdVjY1qlvzM4W6FLXgqMJGWnpgheblBRe7qbVILm70UsOUwC
bghtwLLk+ebLRZ5Vciq2YJ1iDYnX91ZNXAQNJBp1W3ZDveU9bvBSpG6mf2y/CQU1
M0TqQNci5sEfc5oY5D7CTs7Fgg/ZLtGnY+72UY5g2TTqe+3F0lWqYUk81j9XRnV2
TnYJwtLj8HrkYpuI+5SXDMoIAscJP8h+ULP/IMve6tNcXnod1DYHG/aDDqLstL1g
F9H3rSXxoapKQN3G1nSbKC6oqEQzOch5hCZm/GFYjQDninoBvdF9AC/HqOMmJmNH
d2hftn2vO2gyP6LPQwRBb7F6Uh/PpNnIATsScmgxeTlXDyFTkKA=
=NDZw
-----END PGP SIGNATURE-----

--6zn93sY2JrH9m7VZ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
