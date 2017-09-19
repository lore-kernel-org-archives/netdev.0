From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net 0/7] Bug fixes for the HNS3 Ethernet Driver for Hip08
 SoC
Date: Tue, 19 Sep 2017 06:59:00 +0300
Message-ID: <20170919035900.GI5788@mtr-leonro.local>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="7SAgGoIHugoKhRwh"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170919010628.175732-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--7SAgGoIHugoKhRwh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 19, 2017 at 02:06:21AM +0100, Salil Mehta wrote:
> This patch set presents some bug fixes for the HNS3 Ethernet driver, identified
> during internal testing & stabilization efforts.
>
> This patch series is meant for Linux 4.14 kernel.
>
> Lipeng (6):
>   net: hns3: get phy addr from NCL_config
>   net: hns3: fix the command used to unmap ring from vector
>   net: hns3: Fix ring and vector map command
>   net: hns3: fix a bug of set mac address
>   net: hns3: set default vlan id to PF
>   net: hns3: Fixes the premature exit of loop when matching clients
>
> Salil Mehta (1):
>   net: hns3: fixes the ether address copy with more appropriate API

1. The fixes patches should have Fixes line and not all of them have
(I didn't look all patches).
2. Please decide on one style: fixes vs. Fixes, fix vs. Fix in the titles
3. Subject should be descriptive and usable, I don't know if it applies
to the "fix a bug of set mac address" patch.

Thanks

>
>  drivers/net/ethernet/hisilicon/hns3/hnae3.c        | 43 +++++-----------------
>  .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  8 +++-
>  .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 20 ++++++++--
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  7 ++--
>  4 files changed, 35 insertions(+), 43 deletions(-)
>
> --
> 2.11.0
>
>

--7SAgGoIHugoKhRwh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnAlgQACgkQ5GN7iDZy
WKeIyA/9ESkbcwj0SNqY874YioMFgm7CpXddZfQawm5rv8PHAk1eiIuG80XXQZfd
uerudhuw5bHeXnhYrQ64bB8CwHNAXb4sD8CUkXXAO5Nc3QcxL5KCfKhFO4YynsCA
40LqXqqkNNTvDBRt89YAfdvdLonPo+WL0sB4rVCmv/LpvVIgFDWqN2vDldL4EUKi
27WurhHoeyFTLc9YeNddfk5kLXlO4526BLEMb485q3eZC6HDaq26kaMJwxhCYgq/
4t+T2JPLvDE/tmrqFcTHJ9ciMovLrzbEilRGIQNPZ2nFHYDhh7JmKC48b207C4vr
4569NRdTrfzRdiNvqHLUE7cPKPFv611+a4lik9zcBerr1583wmuFhvnyzn4HY00i
ykSF4iCO+mNuQ5OpPTYsfeatrJlBlAnwBAMWN8QyCOFXM3qiZacxalnxxV94mXft
dVF5pc80+U4Oeqo0b3/8ZLIglQb5JdF3ptAvYNYo7Xh4Mrv6UOoKLUYl59/DyDKv
lvBvk2i+acDej/4R7E+BwDIM72AbM0HGRyUaxZpMOvNsmC1kHaYHPD457N30hHzc
0vDnnEcX06rABD1eWgK+9E9DYo1zMh0Ll0nrB+mQYkE6nuQ/7dU/PS85UFksgDik
Wsg1N2xPm30GABXKLjdZSb8XOyQmydyYnBUxPS3niR/E3Zeq/Vc=
=+9ih
-----END PGP SIGNATURE-----

--7SAgGoIHugoKhRwh--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
