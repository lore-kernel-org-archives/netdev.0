From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 12/15] RDMA/cma: make config_item_type const
Date: Tue, 17 Oct 2017 13:56:41 +0300
Message-ID: <20171017105641.GN2106@mtr-leonro.local>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
 <1508167134-6243-13-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="qhD8kUEc5MK9MdKG"
Cc: julia.lawall-L2FTfq7BK8M@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        knaack.h-Mmb7MZpHnFY@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org,
        kishon-l0cyMroinI0@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org, jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org,
        ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mfasheh-rOS7oXVqrJRBDgjK7y7TUQ@public.gmane.org,
        linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        cluster-devel@redh
To: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1508167134-6243-13-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--qhD8kUEc5MK9MdKG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 16, 2017 at 05:18:51PM +0200, Bhumika Goyal wrote:
> Make these structures const as they are either passed to the functions
> having the argument as const or stored as a reference in the "ci_type"
> const field of a config_item structure.
>
> Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> * Changes in v2- Combine all the followup patches and the constification
> patches into a series.
>
>  drivers/infiniband/core/cma_configfs.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--qhD8kUEc5MK9MdKG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnl4ekACgkQ5GN7iDZy
WKeXjhAAianTJjpS3Q7Amt68dVak+Zy2iyjm1IkgvBu0u2FdrPHb15D8sEr4jOg+
NxfJ4zH+C2fgBYvEXa9+aEIb72WSQHQoA1G8EKdfP+D6ci1eHZ60yG7sxmMi2Bsr
4hCGCe/KiiftWsk47Y7KBrHj92HusNRTcM48a1wYNUoAmHq4fRjLyhL8uIVsXl3o
Af/DvQP4d37U9UHMFiekaFgT2K0TfHK1uKUSB7AMvxVb9U+FZFKEXnq6Vcp45uZY
1FzTXYbSC0ckAFd+iYDxly3lsSAekPa5rUV+MLSwKOATP3vksOh+tQ1prJMnT1Kf
QVsN6lRqTTLMmrM1QgRvkT6PjhAQo6qcNgAfkCQjK4V6s9FQdJg95japfefDz6rq
BTwez0ekKroiVtO/8bcJNyDXCpRKNH9EZuQzRL9gqddhe8/xaqc9VrJHDuH93p1q
NimWkby6EiDvXhnGuEaO7P5gmubTbgx+D26n+g9XDPML5orUX2DZ1H6DBD4YR6/h
4BjPfk2eL92oXLLM88PPFf60ctQ8VIgiVq7oUEfBL3QLwFv0NQoZsOTilPrucJiW
lHe1J1t8FO/mDMb4jFXsbeQi8mmKX5ICCwwMKt8Fw9NRzN/mXqRpnC4jzQ13qbKT
viWVz2ZixqgMKLCGUfstRliyiIFmBZhoBNMf2SYEGS+yAOUYca8=
=kyDA
-----END PGP SIGNATURE-----

--qhD8kUEc5MK9MdKG--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
