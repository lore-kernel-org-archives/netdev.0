From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC PATCH net-next] net: ipv6: Add a sysctl to make optimistic
 addresses useful candidates
Date: Mon, 20 Oct 2014 23:40:15 +0100
Message-ID: <1413844815.31953.32.camel@decadent.org.uk>
References: <1413520309-13814-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8t8A8pso8psRG3gJqIvE"
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	lorenzo@google.com, edumazet@google.com
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43284 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753380AbaJTWka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 18:40:30 -0400
In-Reply-To: <1413520309-13814-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8t8A8pso8psRG3gJqIvE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-17 at 13:31 +0900, Erik Kline wrote:
[...]
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -154,6 +154,7 @@ enum {
>  	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
>  	DEVCONF_PROXY_NDP,
>  	DEVCONF_OPTIMISTIC_DAD,
> +	DEVCONF_USE_OPTIMISTIC,
>  	DEVCONF_ACCEPT_SOURCE_ROUTE,
>  	DEVCONF_MC_FORWARDING,
>  	DEVCONF_DISABLE_IPV6,
[...]

As this is UAPI, the new entry must be added at the end of the
enumeration (well, before DEVCONF_MAX).

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-8t8A8pso8psRG3gJqIvE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVEWPVOe/yOyVhhEJAQo8ExAAqu28RQflAUEWW0lnP3yIRJ5MO+OR/ghk
GpANV6essdljWsRuZQ9JgMSi8o1bK5XqB3jLtUPdi4bC1hLi0nRLpTjmPpA+JGFf
wMn9f1jZ0PstEI+jMBTS4epeeJxRtGkFE7SV+xA/PnT7HXO/YUnu1exDmGiWa617
Zv9TDuuzvqZSuqCt1Qtf8EdVuFgxeEDlqHRhueFkc5R0PSfGF26k+3Th/H7XkYTu
yGRafKtBJEUBMDbVDzGThGtyVWoMKPX4RGKDJhCAc3JsABggixmWjzStygVhoze7
1F9OLsP0rxZFJJUmXZ2Su6NdXGGdFAG70w5lHCln6zWLiNwEYqgtCEmZUbEdgmm9
TnFcO0y9Asmf8Ai5p++nEMn+q0UnATwq2eFOzPOIvhsVbVJbgEgAI/zNgTP1N3xb
ms/uZbmJxBFnOl42lkZxJpaIC3u6KPUnjuo2tEodlXHk6N+wxiio5K/4rMMJ/N+t
Q+dDS/T3yOtPbYMzpRXoHoQh7rB0mUK81FnLxkidCuy33gecCyQnirq+1GkN38Ly
wjSD1zlSd4G1Mt/ZWV7NmRHHhMRKpLLa5JrYZfY9CHSqORiV0KeqRekWOKflAUCq
+6MRoFoNgtPqHOSpfhmeAcSIRTDjj1ZCd4ScdvWxApP872fio7hNO/1r7HCJhYpH
erf3ArY7qyQ=
=KNFN
-----END PGP SIGNATURE-----

--=-8t8A8pso8psRG3gJqIvE--
