From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 V3 0/4] RDMAtool
Date: Mon, 10 Jul 2017 19:01:44 +0300
Message-ID: <20170710160144.GN1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170710080230.GD1853@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="xwxKudPUn/iIKJJG"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170710080230.GD1853@nanopsycho>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--xwxKudPUn/iIKJJG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 10, 2017 at 10:02:30AM +0200, Jiri Pirko wrote:
> Tue, Jul 04, 2017 at 09:55:37AM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
> >Hi,
> >
> >This is third version of series implementing the RDAMtool -  the tool
> >to configure RDMA devices. The initial proposal was sent as RFC [1] and
> >was based on sysfs entries as POC.
> >
> >The current series was rewritten completely to work with RDMA netlinks as
> >a source of user<->kernel communications. In order to achieve that, the
> >RDMA netlinks were extensively refactored and modernized [2, 3, 4 and 5].
> >
> >The following is an example of various runs on my machine with 5 devices
> >(4 in IB mode and one in Ethernet mode)
> >
> >### Without parameters
> >$ rdma
> >Usage: rdma [ OPTIONS ] OBJECT { COMMAND | help }
> >where  OBJECT := { dev | link | help }
> >       OPTIONS := { -V[ersion] | -d[etails]}
>
> What about json output? You will need it sooner than later. It will
> prevent you from a lot of headaches if you implement it right away.
> Lesson learned...

I'm planning to do it in the coming kernel cycle.

Thanks

--xwxKudPUn/iIKJJG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlljpOcACgkQ5GN7iDZy
WKd3VA//SXbLsxzgQJUZVnumnlQVzbL74SYNpVegeIxGJ9oy92YoOCrKrHx98mp6
LnKtlaHc10/W/kCtFZh7a07Ay5cPitP3LknaNPQhmA0JJRv1g+pdjCWbA7Uz8WQZ
w8kebstofGv6OKi38JnrWLznbi07kpzogBBkO1CoM8DWpJ/NgqEGfE1Jb41KP/K3
fgvsFB8JFWUbbYMRBijCt7IjV0hYM+r48En8w82HmLiBALjGJnegheaVU8w7Pa4y
tfMX8GfWqBp34xW781e0qTQTTnub5a63dKKqDYUhOh/fZPZuaFoUvP10++sn3j8q
ymX7hwhbIwFhYQbt5MTGuRhHshby2RAYx+hhgXxJIEjc+TjL2CgxOm9bJ+b7Ea3Q
PCjlkRxHXvkab0Zc2ZvU1XjaKuxDNCq7kEcVGjdoQR4cvaJMWH9+AMATk3a+vn6e
0O1ITw7Prqx3/gXh20Vg8+qKVXcCShr4NlPjmE37+M6t+ZsWuqkorEtZpKIs0KsN
b4w53Ynx786E6DUiUYdFpTOUkAK/q6TYtnbr9onfXg8etDdSjlpDg3olcfBGQ+yi
vt0ycAkFafu9hv2DBg7wiXMEAV7iTgLwoWWvn1FDtVjGK2A2eOnX5BdJ6+TyizY8
XyIEph8Asv6qV7bgiqYcI0Lp0UFMylnO+nJxcX8ea9yLgyHrtvQ=
=1ZLj
-----END PGP SIGNATURE-----

--xwxKudPUn/iIKJJG--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
