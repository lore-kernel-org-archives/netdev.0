From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] wan: kill 3 "unused" warnings
Date: Fri, 19 Sep 2003 22:44:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919224428.A7296@electric-eye.fr.zoreil.com>
References: <20030919113252.67949bc8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, ncorbic@sangoma.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030919113252.67949bc8.rddunlap@osdl.org>; from rddunlap@osdl.org on Fri, Sep 19, 2003 at 11:32:52AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap <rddunlap@osdl.org> :
[...]
> patch_name:	dscc_warnings.patch
> patch_version:	2003-09-19.11:18:03
> author:		Randy.Dunlap <rddunlap@osdl.org>
> description:	kill 3 warnings (label, functions not used);
> product:	Linux
> product_versions: 2.6.0-test5
> maintainer:	Nenad Corbic <ncorbic@sangoma.com>

?

$ less MAINTAINERS
[...]
DSCC4 DRIVER
P:      Fran=E7ois Romieu
M:      romieu@cogenit.fr
M:      romieu@ensta.fr
S:      Maintained

> diffstat:	=3D
>  drivers/net/wan/dscc4.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletion(-)
>=20
>=20
> diff -Naurp ./drivers/net/wan/dscc4.c~warnings ./drivers/net/wan/dscc4.=
c
> --- ./drivers/net/wan/dscc4.c~warnings	2003-09-08 12:49:58.000000000 -0=
700
> +++ ./drivers/net/wan/dscc4.c	2003-09-19 11:14:59.000000000 -0700
[...]
> @@ -1093,7 +1095,6 @@ done:
> =20
>  err_disable_scc_events:
>  	scc_writel(0xffffffff, dpriv, dev, IMR);
> -err_free_ring:
>  	scc_patchl(PowerUp | Vis, 0, dpriv, dev, CCR0);
>  	dscc4_release_ring(dpriv);
>  err_out:

The warning reminds that the call to dscc4_release_ring() is plain wrong
(hmmm... as well as calling dscc4_release_ring() in dscc4_close() *doh*).

Ok, I will fix this crap.

--
Ueimor
