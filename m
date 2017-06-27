From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 20:46:15 +0300
Message-ID: <20170627174615.GV1248@mtr-leonro.local>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="KI6XeYrntNhU1GwB"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170627173735.GA5162-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--KI6XeYrntNhU1GwB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 27, 2017 at 11:37:35AM -0600, Jason Gunthorpe wrote:
> On Tue, Jun 27, 2017 at 08:33:01PM +0300, Leon Romanovsky wrote:
>
> > My initial plan was to put all parsers under their respective names, in
> > the similar way as I did for caps: $ rdma dev show mlx5_4 caps
>
> I think you should have a useful summary display similar to 'ip a' and
> other commands.
>
> guid(s), subnet prefix or default gid for IB, lid/lmc, link state,
> speed, mtu, pkeys protocol(s)

It will, but before I would like to see this tool be a part of
iproute2, so other people will be able to extend it in addition
to me.

Are you fine with the proposed code?

>
> A show gid table command makes sense for rocee where it can show the
> gid and the IP binding for it, rocee mode, etc..
>
> Jason

--KI6XeYrntNhU1GwB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllSmeYACgkQ5GN7iDZy
WKfgSQ//RPxqGNDNipavmn5gMFYI/nbPee7mR9JdqFVw+CRO2votvVrYChh3oAl0
c3LvUcQGqvG25O0PJVYPynMl+8qW3UT0dc3G1V/fJIavssY40knrdelU9n1QLkmF
zV00H5vDwQRWRXeUdwZxJ58yKO2sMfF48qst04qEVHyfL0gWy1anNGKheIAT7x3y
RYXnW8RBD5eRTA7AhB4QQOYabaKfq/QYN9CJgBRgYxJxX8B6X7HkZuwdBrfyOcPp
e+eIH7YfE+L71XbSF6pOoegemCVyYagWGehMBBRLwnNgHkzMCnOML6BlMxOZQ7gP
QlO5qgJOoX9i828G/Ek6xsR/EZ4dj8Z2zp7SI++qKgOwHvoSe0WSH6hURSZYKMcR
DjeIdquxLGClzYBF0DPlw/GlgHBP9quoEV7klG5nc3LxBqvmu7Ezjy8IkZGA8IG0
6zG+eJa7JPlGxvf2Rkq2xylElDo4mu/ljt/Daa5KJ1IH0omYWe1nnOtQjLsmZ2t8
RKh9Z4tEJaTORb6Gc37eD1o7t1eRQGiQluMKEssvcsZAq8jeZ2WqBJEayfeayS4Q
DglWIzjVcdAv4OJMf2fAp8gNvTeCgyjzOmvBLpjg7ZelEw38dFN1gqCkTibEctWU
AQNVnNdME5Fdbd3QSIzX/6pex/DPqIcCdi6RjWneroMKG+il59Q=
=tf41
-----END PGP SIGNATURE-----

--KI6XeYrntNhU1GwB--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
