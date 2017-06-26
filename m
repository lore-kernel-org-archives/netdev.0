From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Mon, 26 Jun 2017 22:21:03 +0300
Message-ID: <20170626192103.GH1248@mtr-leonro.local>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="RbAp84Sx/Z5HOs1D"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170626182924.GB16026-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--RbAp84Sx/Z5HOs1D
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 26, 2017 at 12:29:24PM -0600, Jason Gunthorpe wrote:
> On Mon, Jun 26, 2017 at 09:21:26PM +0300, Leon Romanovsky wrote:
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > Add parsing interface for the device capability flags
> >
> > $ rdma dev show
> > 1: mlx5_0: caps 0x1257e1c26
>
> This seems very un ip-like. I wouldn't show an undecoded hex value
> like that, it isn't really useful.

It is first supported field, after new fields will be added, we will
have very similar to ip interface.

1: mlx5_0: caps 0x1257e1c2 key_1 val_1 key_2 val_2 ....

The value are presented as is can be usable as an input for different scripts.

>
> > $ rdma dev show mlx5_4 caps
> > 5: mlx5_4: caps 0x1257e1c26
> > Bit	Description
> >  01	DEVICE_BAD_PKEY_CNTR
> >  02	DEVICE_BAD_QKEY_CNTR
>
> This table also seems un ip-like, the usual format is a list of words,
> I think.

It is true for key<->value data, but it is less obvious for bit parsing.
Internally, I tried to present them as list and it was ugly like hell
without any chance (without extra parsing) to actual see if specific
capability is present or no.

The question is: is such presentation usable and does it make sense?

>
> > $ rdma dev show mlx5_4 cap_flags
> > Unknown parameter 'caps_flags'.
>
> ?

An example of "wrong" parameter. There is no such caps_flags.

>
> Jason

--RbAp84Sx/Z5HOs1D
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllRXp8ACgkQ5GN7iDZy
WKciuBAAtiL/WbMAgcdzNMS1TLr+RuIA8Nimb5vCLZcG61fwqi212pPQv94avDB9
ocLfFgccGoxJulAqExVktYC9JLhF+0BhOuZzh2g6OGeA7QEZcS2XK3+x0m/egm12
+NSf8YJzWxESFOGzYbupBIA/NVLRePbJgHsgdmCqZiV3fYfxWqNzycgdhPia9dtM
snNAMSrAw0yxAdmuAf7QQXAtLgXz509ukWe6UoQEdWB5LE6EDJggF45bYPfSQoAO
Vf4+ZYu6Qxv0K9p1jWb6ST6lrKC0gNA/qDIuToXG8HuEfIQl1WU6MM+SjBvou9vV
BI9gFwSZQCZCW+S/yUMVVHxZq/9uvvXr6ymr8IX4KPq4Nhf/xb0ZFTL0G45Ca9XU
Jr/MfF1en+67WnyVr1mk5QEyxHn/8VqGIgis7uuT2R0IyjYNXyO2t5FK0eVYa4FA
1ZFsqqHj3F6ghpFbzR0xR2CcVfkOW8F1VV0Lgo2SVE0dQJ33TK1bB4KtP+leeK7L
cOynciuOifU3x4SBe2CXeDDOOXAJZNWme50RPqp/QU3AxOa4QLwWFeC7xXGfm7ZV
6NPe2IyzCxo4tA1Hy5e2ltAc+09VZgvFE0pE1RAap8XvdG9uXwRp12Ajv0Lc4not
zqPsBzBwofV3AfmCjdHYt1leaDYNe1Y10R4QMxSD9yFXrHof3+o=
=6wnq
-----END PGP SIGNATURE-----

--RbAp84Sx/Z5HOs1D--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
