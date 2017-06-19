From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next 12/13] net: ena: change validate_tx_req_id() to
 be inline function
Date: Mon, 19 Jun 2017 07:56:04 +0300
Message-ID: <20170619045604.GJ17846@mtr-leonro.local>
References: <1497785298-13468-1-git-send-email-netanel@amazon.com>
 <1497785298-13468-13-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="9aCKuHbn5v2q3RVc"
Cc: davem@davemloft.net, netdev@vger.kernel.org, dwmw@amazon.com,
        zorik@amazon.com, matua@amazon.com, saeedb@amazon.com,
        msw@amazon.com, aliguori@amazon.com, nafea@amazon.com,
        evgenys@amazon.com
To: netanel@amazon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:50810 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750790AbdFSE4I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 00:56:08 -0400
Content-Disposition: inline
In-Reply-To: <1497785298-13468-13-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9aCKuHbn5v2q3RVc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Jun 18, 2017 at 02:28:17PM +0300, netanel@amazon.com wrote:
> From: Netanel Belgazal <netanel@amazon.com>
>
> for optimization purpose, change validate_tx_req_id() to be
> inline function.
>
> Signed-off-by: Netanel Belgazal <netanel@amazon.com>
> ---
>  drivers/net/ethernet/amazon/ena/ena_netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> index 4540cd3d9f5f..da14b78cc87c 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> @@ -698,7 +698,7 @@ static void ena_destroy_all_io_queues(struct ena_adapter *adapter)
>  	ena_destroy_all_rx_queues(adapter);
>  }
>
> -static int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_id)
> +static inline int validate_tx_req_id(struct ena_ring *tx_ring, u16 req_id)

inline in C-file?

Please read Documentation/process/coding-style.rst,
15) The inline disease" section why it is wrong and if you anyway
insists on doing it, please provide support of your claim "optimization
purposes" and show what and how exactly your optimization happened.

Thanks


>  {
>  	struct ena_tx_buffer *tx_info = NULL;
>
> --
> 2.7.4
>

--9aCKuHbn5v2q3RVc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllHWWQACgkQ5GN7iDZy
WKerNg/+OLuObtG/myfaeeH1q3puA7XXmjZUjlPAILqjmAUuai3ZXWYfMpeo41Xf
b3ktllP6OodO57ckyvlF/1BKZAllidV2MlWI+Nf1GBMOY48CK816dvoXI4gn8Kj2
ogM4I63lGGrhJf84q6CVnFjcfXxCcwZr5PywAruvWuxWiOJNAieWrWguu5CX9VT8
mtwUt6+EsE21xNO+/0M2ArdB7Zl2HE44mOL8hG8pRyzcV1yMvSZpoTUpIkojjNoa
/hv/FN+m2Y6VG/aWjOfQoOjRmw8MeYI5nb0oMbJa4kHZvKY1RAcUSyJ3TrsxdPYU
/lXevwLstfBMxv6HQ8Zjcx1p4DwSObHoVpH3hrvrTmle174w0IAinqiBazcxj6jV
745hATnc3bQ0NpJUaH+/w4OFedrk4O3UiDmxDArWf7vS7vG6mswvLpAo3DYSPvQK
Od8snj8NWsBT132P/R2eLGkC/pmPJHv33k3uRgy9h/0tQq/0d9RaDjf0wDFi1iwy
4TXs5mfjX3TaVfanmuKH6QF4OJUJRprvB6dKT4lY5LC6sk8Uz/xJbN5FmmLiloLF
HJUOUzN2LEbFGqK7V8K+Q6D90x4HKo5yYKLyYOzl0GH/pqbjWpZJDB6m97q83X38
eGweZJl2rKVQUC5/jNsfDeTt9PWroqvUAV6vlrKJCX5nwASUmM4=
=fmLx
-----END PGP SIGNATURE-----

--9aCKuHbn5v2q3RVc--
