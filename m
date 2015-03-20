From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] net: bcmgenet: add support for Hardware Filter
 Block
Date: Fri, 20 Mar 2015 23:00:06 +0000
Message-ID: <1426892406.32382.11.camel@decadent.org.uk>
References: <20150313214500.DD4C42211CA@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nxWraMHWaRl2OalHv+fC"
Cc: netdev@vger.kernel.org, davem@davemloft.net, f.fainelli@gmail.com,
	jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50086 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbbCTXAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 19:00:20 -0400
In-Reply-To: <20150313214500.DD4C42211CA@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nxWraMHWaRl2OalHv+fC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-13 at 14:45 -0700, Petri Gynther wrote:
> Add support for Hardware Filter Block (HFB) so that incoming Rx traffic
> can be matched and directed to desired Rx queues.
[...]
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
[...]
> + * To add the filter to HFB and direct the traffic to Rx queue 0, call:
> + * bcmgenet_hfb_add_filter(priv, hfb_filter_ipv4_udp,
> + *                         ARRAY_SIZE(hfb_filter_ipv4_udp), 0);
> + */
> +int bcmgenet_hfb_add_filter(struct bcmgenet_priv *priv, u32 *f_data,
> +			    u32 f_length, u32 rx_queue)
[...]

But nothing calls it.  Are you intending to implement ethtool rxnfc ops?

Ben.

--=20
Ben Hutchings
All extremists should be taken out and shot.


--=-nxWraMHWaRl2OalHv+fC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQymfOe/yOyVhhEJAQqhERAAxPdEodntcC61uptNJB3O9ES/bGi6HQkr
tgjtW5ZA7uOVa5V04XTME33JrK2DnJJv0fsMvicvb1/DmL3WpmiG99ktc+QsxMhb
A/M+ASK3OtC3KwcLdc/cSH1VpGuKAib791TOpFpsO/V5LndaHgevTvcEClX3ZBX8
1UaMyMvC2l+V8Fzp0f1yMFoM5gAD+Lbkb6MeK9VpJvyxZTKwAFiecYV3MnKWn+uD
EqfF9xO53SsnbA9OfQi5dafzjnUJUDt9FH7v/AdcQ/XgGEVwTITT40nUzy0mk5lu
C3eirkCCmzfK0wZtLcRR/cY5k2mRVufGuH5jCeU+i6vwKY/UKhHqhWQTAgjMkl1Z
oiHPjqsD38QTq1+GK29FiMj+h6rAOmmIsdxjjQwNObi8XA24z+rzwbhYqZBI27CI
s7Vr9TTRsG3HA7Ekl9dePYcm0qLieRBKgRQXMIkpZGcibUogIvO9kIFy5iImpzzz
o5WjB29QLyj6AZTeosYaRLjoPXOHjsgFRVvVlC4Iu2O69h4DzaMx9+EtyPJoKf12
zzKdnObF0RwWsids+O5XzJRvgEkSJZzpEcrWxkC5pEGolP4SFAjXBYDzxPw7aars
t0gN24laah/tZI6Ltk5GgJNy6YcMcMEJWBhZxxhQqL1UoXwxWuo9jImVPK0xIRMq
dIifLXt6Etg=
=2ho5
-----END PGP SIGNATURE-----

--=-nxWraMHWaRl2OalHv+fC--
