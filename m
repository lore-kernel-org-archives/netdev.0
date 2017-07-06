From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v2 net-next] liquidio: fix bug in soft reset failure
 detection
Date: Thu, 6 Jul 2017 10:21:00 +0300
Message-ID: <20170706072100.GR1528@mtr-leonro.local>
References: <20170705185927.GA1058@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="jITzwD3HDGXid3BE"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43808 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752747AbdGFHVF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 03:21:05 -0400
Content-Disposition: inline
In-Reply-To: <20170705185927.GA1058@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jITzwD3HDGXid3BE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 05, 2017 at 11:59:27AM -0700, Felix Manlunas wrote:
> From: Derek Chickles <derek.chickles@cavium.com>
>
> The code that detects a failed soft reset of Octeon is comparing the wrong
> value against the reset value of the Octeon SLI_SCRATCH_1 register,
> resulting in an inability to detect a soft reset failure.  Fix it by using
> the correct value in the comparison, which is any non-zero value.
>
> Fixes: f21fb3ed364b ("Add support of Cavium Liquidio ethernet adapters")
> Fixes: c0eab5b3580a ("liquidio: CN23XX firmware download")
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
> Patch Changelog:
>  v2: Revise patch comment, remove unnecessary "!= 0x0ULL" in if statements,
>      and add "Fixes:" tags
>
>  drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c | 2 +-
>  drivers/net/ethernet/cavium/liquidio/cn66xx_device.c    | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--jITzwD3HDGXid3BE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlld5NwACgkQ5GN7iDZy
WKeLGg/8CNkysryY2NWYFLIB0TdwnQmu+tDnogWQ9+V5BYfKvfPdUccZBqZ14BeC
Lene+n4sAgPfDaLrxnvRkFthfDE17Mq1YeUyAnKWUZcziEP2olZhsyY1w/N+k/Am
DJQCfjcm2tIvXDyvYiDqyITE6M+MK/1lbOHW7tiBjORxC8ygD/ZaL5T7gkgIIj76
moEXV+Fa6myAIrr/Hk3LXauLXXj2xBiaTTRIrLZY0iBYByODe4CECBAAvflVTL3i
NkfPYXd3N2a9/rKnsXnfSUv9Tgbj0O63U0ZhA99XmBmzDilNtWtVS6CB7AC19BsH
GLxnRYXuk+6WFoOh+YHY85C+Ic+BrgGSLgUtEsuegMHwsslBBVye1Grz9+tlHyMZ
RRbQvZATSxW5rp/Zl/cbX2y90K9zJUhPG0YfpFkQr1HcywnFoBZ9giEFlAMZtgvK
r9YwMg/7Xb27t8kFaF7NfSARTptDMPz0J50oO4N6IVE6YLeET7kb6fxuM5K/Blst
eU5sbFU7W93FEUPIDrudSBnMJ9/L1O6jQyGqIiuK4rgv4YZRmo+9wrQ3axFIYmrD
vd95tHnjjRvnz5Iezj+wNAfmhKadfikG5OJSCKd9+UIaAia109FFIU8risq7+vix
6pdwspwO+fI6xrbC7avZrzOvzIQ7n/AYzJSM9HcdfomHofQqyV0=
=qVQM
-----END PGP SIGNATURE-----

--jITzwD3HDGXid3BE--
