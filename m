From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next] liquidio: update debug console logging mechanism
Date: Sun, 13 Aug 2017 08:55:49 +0300
Message-ID: <20170813055549.GO24282@mtr-leonro.local>
References: <20170812014314.GA1012@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="lZZ4ablUVnt2XgAh"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, ricardo.farrington@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:58314 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdHMFzx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Aug 2017 01:55:53 -0400
Content-Disposition: inline
In-Reply-To: <20170812014314.GA1012@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lZZ4ablUVnt2XgAh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Aug 11, 2017 at 06:43:14PM -0700, Felix Manlunas wrote:
> From: Rick Farrington <ricardo.farrington@cavium.com>
>
> - remove logging dependency upon global func octeon_console_debug_enabled()
> - abstract debug console logging using console structure (via function ptr)
>   to allow for more flexible logging
>
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_main.c    | 44 +++++++++++++++++-
>  .../net/ethernet/cavium/liquidio/octeon_console.c  | 54 ++++++++++++++--------
>  .../net/ethernet/cavium/liquidio/octeon_device.h   | 17 +++++--
>  3 files changed, 90 insertions(+), 25 deletions(-)
>

I'm probably missing something important, but why do you need your custom console
implementation if kernel is full of such built-in options?

Thanks

--lZZ4ablUVnt2XgAh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmP6eUACgkQ5GN7iDZy
WKesiRAAurk/YTtwUkA6jteCNtOuvmyDYq2aPOCyTEDd/qc3xa3YYQ90DmwJUWYF
OyMcRFXQRFKF9qJryByYqPD5I2nm3sBjDnetDFEvSYPOLBCreK75x48ujyUyCeUL
4ww27eGeXLwEcEKxwTWtpjy6ol7wGxU1HqpIf8MP7K6w+9fWqEwwdMohuvVMxkrW
LfK55dAT2xEjGK0hLgrH9TG9rKXN8VidfQosB5COWer354NQFLCEI9rno5uz9KLv
2E3TSmqfImg8LoHfW3XFeGcsDVmeqKK1OL+7MjykFhibkHRxsy7TAxQMvSXwQzYy
Cdwz96MYxkOG9GNhZAIb72l9NkY7C6FhoWMnYg/IHN1bkxogDecHfoP9r24GS+Ai
1Gg3GrxiCb9LU8O+5nqGhNBrJfgBXgw/uSyoPbJwvHOsN0a3srfQz21WDjp9g//V
tufiY3QYtG2+Rvw5WIIFgfBjcyq6P/qseDcftXRqLf0acbk58Mzyi7emPvIuYlci
uVgroUc6eKTRQFdicXMx7ouitEOMExc5zN/z4E4iynbBFFZbSc4yJpeped4yk0lJ
D8Apztx7DR2lRuc0JSDCmEGsVyFJGZMFtx4k4T7TBK328BPmZi7+qGmU+5Sa6tj9
6ETcqWhbcPCo6NlbDxN89LUUVBjoiUl0V+pjlehL6T/p9/rDozY=
=1QIv
-----END PGP SIGNATURE-----

--lZZ4ablUVnt2XgAh--
