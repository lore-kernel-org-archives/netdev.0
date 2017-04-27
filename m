From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next] mlx5: work around unused function warning
Date: Thu, 27 Apr 2017 16:13:12 +0300
Message-ID: <20170427131312.GI14088@mtr-leonro.local>
References: <20170427110421.2431598-1-arnd@arndb.de>
 <20170427115513.GH14088@mtr-leonro.local>
 <CAK8P3a0kX4uNLBvLAHrhtmUc7eBLmD6dXA8=xxY+xJ4OsGFJbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="hdMwqcnXK86+cyrC"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAK8P3a0kX4uNLBvLAHrhtmUc7eBLmD6dXA8=xxY+xJ4OsGFJbg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--hdMwqcnXK86+cyrC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 27, 2017 at 02:04:15PM +0200, Arnd Bergmann wrote:
> On Thu, Apr 27, 2017 at 1:55 PM, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> > On Thu, Apr 27, 2017 at 01:04:02PM +0200, Arnd Bergmann wrote:
> >> The previous patch addressed a sparse warning but replaced it with a
> >> compiler warning when CONFIG_MODULES is disabled:
> >>
> >> drivers/net/ethernet/mellanox/mlx5/core/ipoib.c:485:13: error: 'mlx5_rdma_netdev_free' defined but not used [-Werror=unused-function]
> >> drivers/net/ethernet/mellanox/mlx5/core/ipoib.c:423:27: error: 'mlx5_rdma_netdev_alloc' defined but not used [-Werror=unused-function]
> >>
> >> We should never export 'static' functions, so this makes them global
> >> again but hides them in another #ifdef like the change before.
> >>
> >> Fixes: a7082ef066f0 ("mlx5: hide unused functions")
> >> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> >
> > Hi Arnd,
> >
> > Thanks for the patch, but Stephen and Saeed already sent patch similar to it.
> > http://marc.info/?l=linux-netdev&m=149288674816288&w=2
>
> That link is for the patch that introduced the warning that I'm fixing here,
> it showed up yesterday in linux-next.
>
> Did you misread my patch, or just give the wrong link?

Sorry, I misread you patch, because I prepared patch which add users for
these functions and didn't notice both "static" and EXPORT_SYMBOLS at the same time.
I will send it in a couple of minutes.

Thanks

>
>       Arnd
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--hdMwqcnXK86+cyrC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkB7mgACgkQ5GN7iDZy
WKfasg//c/K7nxVllkX26KHp0Vpmh1yNiqs/LJEG3vBc2GPv6hDytmupE0TMUEIU
bo6oHowYUCe3MnBHNLeNDo9Bumq5kGwsmwPv6UP73NxqPE97qmhDAiXX0abBmrin
GD76DejozoHEelGImceTrzFyZTRGbhH3SdBDRB1hs3Kz+VrTK+iJvFCVyz7/XbSK
utC7AiQLDd8AAAmkzhITo++bHiJN/k2ks/2DGcDhhlDMCZv/9NzSU972SpGDj4NI
tvaUDXHOweh8/hWnAkvvZqSNF8FZgCXNivhbSiyLup12t2MKOksbdyV9QkwahcJU
vrx5s34ZFjV+RjFH8HrJGFYORf08DIFWHRV1qHWDK7FcSAhJOS9WITn1GKByl2R2
qAQUX8Qhksg83AQs75EZDZNC7rj3RG2tB/nvxzDFWOagxRKi4L5ngYm2UFZYhG6M
Oy8e/MynLN1O3KnaK5nrTz4sQvuFVhcyabsBX6Ooz6ixUIrNR1ghJP6uXRmi4Er4
ti8BNIxmLmoWmKyQOCLkrwm0Up6VTK/eEsIj8TCMBvgVYLj+huyDnyE8syiFhVY3
sFgOSuqkpoZL01AjIUZqQqzwLasGZuturYGZMnsVGp/+IVoIxNyruwGBgO3nW2Gm
mkrwCfdMu4hgGZsYVrtCNyqPmxt2H2IIm/y8Fu/lndm4MHqZUGc=
=hT5S
-----END PGP SIGNATURE-----

--hdMwqcnXK86+cyrC--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
