From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] of: fsl/fman: reuse the fixed node parsing code
Date: Sat, 08 Aug 2015 10:32:43 -0700
Message-ID: <55C63D3B.5020005@gmail.com>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Igal.Liberman-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438785745-15517-1-git-send-email-madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

CC'ing Stas,

Le 08/05/15 07:42, Madalin Bucur a =C3=A9crit :
> The FMan MAC configuration code needs the speed and duplex informatio=
n
> for fixed-link interfaces that is parsed now by the of function
> of_phy_register_fixed_link(). This parses the fixed-link parameters b=
ut
> does not expose to the caller neither the phy_device pointer nor the
> status struct where it loads the fixed-link params. By extracting the
> fixed-link parsing code from of_phy_register_fixed_link() into a
> separate function the parsed values are made available without changi=
ng
> the existing API. This change also removes a small redundancy in the
> previous code calling fixed_phy_register().

I will look into this shortly, sorry for the delay.

>=20
> The FMan patch relies on the latest FMan driver v4 submission by Igal=
 Liberman:
> https://patchwork.ozlabs.org/project/netdev/list/?submitter=3DIgal.Li=
berman&state=3D*&q=3Dv4
>=20
> Madalin Bucur (2):
>   of: separate fixed link parsing from registration
>   fsl_fman: use fixed_phy_status for MEMAC
>=20
>  .../ethernet/freescale/fman/flib/fsl_fman_memac.h  |  6 ++-
>  drivers/net/ethernet/freescale/fman/inc/mac.h      |  2 +-
>  drivers/net/ethernet/freescale/fman/mac/fm_memac.c | 42 ++++++++++++=
-----
>  drivers/net/ethernet/freescale/fman/mac/fm_memac.h |  3 +-
>  drivers/net/ethernet/freescale/fman/mac/mac.c      | 18 ++++++--
>  drivers/of/of_mdio.c                               | 52 ++++++++++++=
++--------
>  include/linux/of_mdio.h                            |  9 ++++
>  7 files changed, 94 insertions(+), 38 deletions(-)
>=20


--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
