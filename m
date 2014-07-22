From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Tue, 22 Jul 2014 18:45:45 +0100
Message-ID: <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>
	 <1406050268-13329-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6xqb44bIQ95qEdU5cx7A"
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42594 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756285AbaGVRpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:45:55 -0400
In-Reply-To: <1406050268-13329-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6xqb44bIQ95qEdU5cx7A
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-07-22 at 23:01 +0530, Govindarajulu Varadarajan wrote:
> This patch adds rx_copybreak support to ethtool.h header file.
> This is used to show/set rx_copybreak using ethtool.
>=20
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  include/uapi/linux/ethtool.h | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index e3c7a71..d2912ad 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -433,10 +433,12 @@ struct ethtool_ringparam {
>  	__u32	rx_mini_max_pending;
>  	__u32	rx_jumbo_max_pending;
>  	__u32	tx_max_pending;
> +	__u32	rx_max_copybreak_pending;
>  	__u32	rx_pending;
>  	__u32	rx_mini_pending;
>  	__u32	rx_jumbo_pending;
>  	__u32	tx_pending;
> +	__u32	rx_copybreak_pending;
>  };
> =20
>  /**

No, you can't rearrange UAPI structures like this.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-6xqb44bIQ95qEdU5cx7A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU86jSee/yOyVhhEJAQp/+xAAu410wwy2GqH2vGsCK56pwaT+Vqp/C/58
KcPJicqlBfTOVXERfzti0vNa1cYBKnaOc1Nl5tuaB4IHGxN4nekiJe9TyMzIXsD9
rMGNcx4QKEfDl7NjYa9Osbj8EMHpC/8oa90hwIEjynocjXb7Lzig6r2QKXu07pYJ
iInpI9A8wIY6Y2ibbrk2qS9sUA2dUMqxjkjLIaEXhmk99LWZO7VFCd2adzfpcLrC
Wf4FR8b+oEzLdaSGidXE6StyBk3mQEGKRalT7bHUPHfsRfKxRdInoUzPTcPQQnmx
iKsRohFaNNSPF22EkPehNFNzTDFePyPX9Q9gEIOyFwuJkwP4OLp9OyxA0IOHvWRI
69xsAQN1KlgQHNLIqGizh3Kx4lNyHSCWo7hnazzx8598w+kiAWSXXAxvdSrzykc3
hzMn672p5bh1O66AKfpeQMeitMu8Wv3yOZg+jS0Co+y5GWG9oDau4JZHFeSClTE3
+MLEzaLBXJHd7yJm1E5ZVhmuzb83RObw4t+/sl3fQ8ZvyM8zDsXW5lTqDHoxC8aE
qgCTIQs0oKhNnRRPBwdgo6WUbMrxfQWPNCapJDfmC9OVul5tbE7PcXgrnC5Pbv9y
xgX2HEAgR5pQN7w5knCUHDseMt3tqQ13HY76T0TtPLhoVkoAwz7HICQ8AnFCd1fk
k54LEUBkK34=
=E5jr
-----END PGP SIGNATURE-----

--=-6xqb44bIQ95qEdU5cx7A--
