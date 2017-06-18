From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH V3 net-next 0/8] Hisilicon Network Subsystem 3 Ethernet
 Driver
Date: Sun, 18 Jun 2017 09:07:36 +0300
Message-ID: <20170618060736.GH17846@mtr-leonro.local>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="4LFBTxd4L5NLO6ly"
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4LFBTxd4L5NLO6ly
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 17, 2017 at 06:24:23PM +0100, Salil Mehta wrote:
> This patch-set contains the support of the HNS3 (Hisilicon Network Subsystem 3)
> Ethernet driver for hip08 family of SoCs and future upcoming SoCs.
>
> Hisilicon's new hip08 SoCs have integrated ethernet based on PCI Express and
> hence there was a need of new driver over the previous HNS driver which is
> already part of the Linux mainline. This new driver is NOT backward
> compatible with HNS.
>
> This current driver is meant to control the Physical Function and there would
> soon be a support of a separate driver for Virtual Function once this base PF
> driver has been accepted. Also, this driver is the ongoing development work and
> HNS3 Ethernet driver would be incrementally enhanced with more new features.
>
> High Level Architecture:
>
>         [ Ethtool ]
> 	   ^  |
>            |  |
>        [Ethernet Client]  [RoCE Client] . . . [ Ethernet Client ]
>     ---------------------------------------------     |
>                          |                            |
>      [ HNAE3 Framework (Register/unregister) ]        |
>                          |                            |
>     ---------------------------------------------     |
>                    [ HNAE Device ]                    |
>                          |                            |
>                    [ HCLGE Layer]                     |
>          ________________|_________________           |
>         |                |                 |          |
>     [ MDIO ]    [ Scheduler/Shaper ]  [ Debugfs ]     |
>         |                |                 |          |
>         |________________|_________________|          |
>                          |                            |
>              [ IMP command Interface ]                |
>     ---------------------------------------------     |
>               HIP08  H A R D W A R E                  *
>
>
> Current patch-set broadly adds the support of the following PF functionality:
>  1. Basic Rx and Tx functionality
>  2. TSO support
>  3. Ethtool support
>  4. HNAE framework and hardware compatability layer
>  5. Scheduler and Shaper support in transmit function
>  6. MDIO support
>  7. kernel build supporrt, Makefiles, Kconfig etc.

Since it is RoCE too, it will be handy to CC: linux-rdma@ for this too.

Thanks

--4LFBTxd4L5NLO6ly
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllGGKgACgkQ5GN7iDZy
WKdcmg/9F5HP3YMuf6AYKxNFV87he/yquVoOmFcV692lEEgjYHnOC7iCIwSoiLhn
+rlvYqTVmuDHMde7AaI/N8XftES5rI/HuDif76KLE/p7B3KSoIJMwSaMufgOyBqd
V+ipIWiY8l86KktDhL/qRnhnO3+C+uxITP97ruVGH4xnlSqB6iqzHs7yF3is1ac3
ytkWn82c50PMV+Vaf1hF/iL2SJfNJpFDvHCorPHkAleoXnKJ27iq5xnuma+o+jQY
6Argj4iJeKXCakQ56MWWjuCfxJliWwC8cBaENYD9Z3Xekzklfu6RrJrRUIMY8+fb
JZsGs/NM5kw8CAI+P+OBqRyP59JL8jJJo+ChJ2wL0rygR4o6o5wIrmBvl/YjTWo5
Y02FZ/jmqxm/nMNtDZb81lKezWG2IxBv6jQhG8JKdqjzaEAtgqq/TEBOabwoYlCA
lzGdgFtM9Y+kzGBzf0CMpJyw1n0Rb8cwI9kMTqcNrgXNxzZUWViwrjtBQMpQsFwW
n7xZiM6SAghGOM9RdxtrHEqpHi1LAUVsKDx0cf3KOJg4B/RVQviqtt0j6XtIAKHH
n+YR7d2CGPF/yOi/OdsHbuoz7s47bhFL2QXgaEGqcpw/R5J5an8odNPkkI88V5Xd
qztRL0XsZiadyAsUs5nyb+U7A5jzcFEhEsqrJK0FSKcV3/ozUmo=
=cgDx
-----END PGP SIGNATURE-----

--4LFBTxd4L5NLO6ly--
