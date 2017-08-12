From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configured if
 only I2C bus is configured
Date: Sat, 12 Aug 2017 17:37:15 +0300
Message-ID: <20170812143715.GN24282@mtr-leonro.local>
References: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="W/D3X8sky0X3AmG5"
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        saeedm@mellanox.com, vadimp@mellanox.com,
        system-sw-low-level@mellanox.com
To: Ohad Oz <ohado@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:52902 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750864AbdHLOhT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 10:37:19 -0400
Content-Disposition: inline
In-Reply-To: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/D3X8sky0X3AmG5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 10, 2017 at 05:11:51PM +0000, Ohad Oz wrote:
> Patch allows Mellanox devices on system with no PCI, but with I2C only.
>

Did you test mlx5 device on such system? Did it work for you?

What is the changelog between v0 and v1 of these patches?


> Signed-off-by: Ohad Oz <ohado@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
> index 84a2007..0949741 100644
> --- a/drivers/net/ethernet/mellanox/Kconfig
> +++ b/drivers/net/ethernet/mellanox/Kconfig
> @@ -5,7 +5,7 @@
>  config NET_VENDOR_MELLANOX
>  	bool "Mellanox devices"
>  	default y
> -	depends on PCI
> +	depends on PCI || I2C
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.
>
> --
> 2.8.0
>

--W/D3X8sky0X3AmG5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmPEpsACgkQ5GN7iDZy
WKf1URAAoroUsZ9NNUfSSs41HjM7hXOEKtAXlY+dIL18MGXY/j1B2IlshTm+180J
SzCeCPnPeOD7pEHfLNwbRmACr1YuKSYNg7veKvV9pPCEi1QmYa0cr0/t0Ad5w86e
wjHZMLQzmMmOSl08zfpet3X42gJnZFuJ3hqSSwRMbKkmvDuOmHO0PI0uNslTZPjp
KILp5087SsMs/LeaCelTVxd3vK4Lm0iqzRTALFx/JcBC47VisLu+gq4eW998cY5S
rcT1YVNll+cKcwE6vyCmamyDDkIWS9YoSqbLK4x+91ytOw9Req0y7JMVTd0C03Im
ip9V5zXdCIjvt+E7VLVcyktfD0cVFrSq3FLFfFMdZf8GrpFElOJ0A582/K5mJCy4
t93hbmqwVfbddpOklYwQrMtmyWr4Oj3QHthnsTHBcdeVoOfPxbJby+CpeoYkP7cg
GNRVpuhAoWTlG1h10So4NmOJopMzRAWF8A8H7UtH8HUB+zJsxBwJYtKCcHI0RC2k
nuP0wlr+NtgEnboLuKRACxgWipBgCmdQ8k4qG6oFbvo5/ygeW+UhuN3PjSZbZwrf
q6gzQvx3LErIBzXvk1XQ6XiF9U2/2Jg+B1bGIO3wDkjukLX/9mLJh+hO9hXC4PJ/
7pjnljjnb6AoGu77NQ1chjs5e7go4IKRrT22JVT7/e858IA6F44=
=g0nm
-----END PGP SIGNATURE-----

--W/D3X8sky0X3AmG5--
