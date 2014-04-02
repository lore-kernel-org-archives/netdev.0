From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH net-next 1/1] sxgbe: use common NET_VENDOR_FOO style.
Date: Wed, 02 Apr 2014 19:35:43 -0400
Message-ID: <67692.1396481743@turing-police.cc.vt.edu>
References: <19617.1396041625@turing-police.cc.vt.edu>
            <20140402231303.GB5013@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1396481743_3292P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Siva Reddy Kallam <siva.kallam@samsung.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:45180 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252AbaDBXjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 19:39:07 -0400
In-Reply-To: Your message of "Thu, 03 Apr 2014 01:13:03 +0200."
             <20140402231303.GB5013@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1396481743_3292P
Content-Type: text/plain; charset=us-ascii

On Thu, 03 Apr 2014 01:13:03 +0200, Francois Romieu said:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>
>  Valdis, is it what you had in mind ?

Works for me.  That brings it in line with other network drivers, feel free
to stick this on:

Acked-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

>  drivers/net/ethernet/samsung/Kconfig       | 24 ++++++++++++++++++++----
>  drivers/net/ethernet/samsung/sxgbe/Kconfig |  9 ---------
>  2 files changed, 20 insertions(+), 13 deletions(-)
>  delete mode 100644 drivers/net/ethernet/samsung/sxgbe/Kconfig
>
> diff --git a/drivers/net/ethernet/samsung/Kconfig b/drivers/net/ethernet/sams
ung/Kconfig
> index 7902341..2360d81 100644
> --- a/drivers/net/ethernet/samsung/Kconfig
> +++ b/drivers/net/ethernet/samsung/Kconfig
> @@ -3,14 +3,30 @@
>  #
>
>  config NET_VENDOR_SAMSUNG
> -	bool "Samsung Ethernet device"
> +	bool "Samsung Ethernet devices"
>  	default y
>  	---help---
> -	  This is the driver for the SXGBE 10G Ethernet IP block found on Samsu
ng
> -	  platforms.
> +	  If you have a network (Ethernet) chipset belonging to this class,
> +	  say Y.
> +
> +	  Note that the answer to this question does not directly affect
> +	  the kernel: saying N will just case the configurator to skip all
> +	  the questions about Samsung chipsets. If you say Y, you will be asked
> +	  for your specific chipset/driver in the following questions.
>
>  if NET_VENDOR_SAMSUNG
>
> -source "drivers/net/ethernet/samsung/sxgbe/Kconfig"
> +config SXGBE_ETH
> +	tristate "Samsung 10G/2.5G/1G SXGBE Ethernet driver"
> +	depends on HAS_IOMEM && HAS_DMA
> +	select PHYLIB
> +	select CRC32
> +	select PTP_1588_CLOCK
> +	---help---
> +	  This is the driver for the SXGBE 10G Ethernet IP block found on
> +	  Samsung platforms.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called samsung-sxgbe.
>
>  endif # NET_VENDOR_SAMSUNG
> diff --git a/drivers/net/ethernet/samsung/sxgbe/Kconfig b/drivers/net/etherne
t/samsung/sxgbe/Kconfig
> deleted file mode 100644
> index d79288c..0000000
> --- a/drivers/net/ethernet/samsung/sxgbe/Kconfig
> +++ /dev/null
> @@ -1,9 +0,0 @@
> -config SXGBE_ETH
> -	tristate "Samsung 10G/2.5G/1G SXGBE Ethernet driver"
> -	depends on HAS_IOMEM && HAS_DMA
> -	select PHYLIB
> -	select CRC32
> -	select PTP_1588_CLOCK
> -	---help---
> -	  This is the driver for the SXGBE 10G Ethernet IP block found on Samsu
ng
> -	  platforms.
> --
> 1.9.0
>



--==_Exmh_1396481743_3292P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUzyezwdmEQWDXROgAQKZ4Q/+NPmozjRowg1twTRnro7IhPYHAMpTa/mv
Fke0UClQPpxvMwvsrQsrIYvMfx0j113H1UxEykFh6QpcN8ydJJkLzPYNWMGkzFRH
DBjmF+KUkmXGmZxujeHIdfJrEDld0g7tKiEG2Js+4EM48m1wWimH6qf89SnLniRb
K+H905sePTLiGztNoN9VxFesEJUNPQ79l5K8+GOhdOjLjYV8s/zyUWj0UAm85FY2
5Jd7RT+aEBYcr7qe7rYbHyFg8IXVslOffxi5k/C+GuvwMqoYOG4fLsukoPCU58NV
VsyCQ7ClTPj090GZBSaySaBPkq9iiM6XjjGYAtOmGfE1vpHCFU61COv+doojilUo
ew/OGulDzy6ILu0QXT5RM4UHbvY3HyiO5NCAqNRyD56zkgcEuZVZdghM+dgw6U2t
elY340gRQyZc+EmAx/DSEuEv6e9GQu4LE9BRycTu7OFVIl6b/FMijRodo6hEC+nh
hgkEp9VW6b8t/FWaFQ1XYJsk5tLw7OI2bQC01OSEQTzvpJLS98dh5H4ao1v6nLtL
zrNVuT1iitJ0V+PQUnSbrjAIjhMWNZGmB9SHl0r+z4v1gqf9zKzHP+huQ3yrTvWA
l6Dhurygfq73AEI2O6IlaOt3N/g+YlZoPwvwmPzWgbf7EOXuTwRhME29KY9EUidt
u1f0y0WtAZg=
=UmUl
-----END PGP SIGNATURE-----

--==_Exmh_1396481743_3292P--
