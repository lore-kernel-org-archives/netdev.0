From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] ixgbe: simplify padding and length checks
Date: Thu, 21 Jun 2012 14:28:09 -0700
Message-ID: <1340314089.2033.16.camel@jtkirshe-mobl>
References: <1340280910-22651-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120621.133807.59441426155221033.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dVJ5mpU3VEO60x25EnKi"
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37717 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760358Ab2FUV2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 17:28:10 -0400
In-Reply-To: <20120621.133807.59441426155221033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dVJ5mpU3VEO60x25EnKi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-06-21 at 13:38 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 21 Jun 2012 05:15:10 -0700
>=20
> > From: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > The check for length <=3D 0 is bogus because length is unsigned, and ne=
twork
> > stack never sends zero length packets (unless it is totally broken).
> >=20
> > The check for really small packets can be optimized (using unlikely)
> > and calling skb_pad directly.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Not really fixing anything and more of a cleanup, so maybe 'net-next'
> instead of 'net' for this guy instead?

Yeah, net-next is fine.  I just verified that the patch applies cleanly
to net-next as well.

--=-dVJ5mpU3VEO60x25EnKi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP45HpAAoJEOVv75VaS+3Oq/gP/A0cPIwXnOUaMW7qzVAkFGcd
k8IByW3YQAFjkYCIYTmdEAnWK535Q6UbUWryuhQs4rDgRLS4Omk1XpQW+BWxqKon
9Cz6vZGgZuz1BGobukKeFnPd3KHbNjT/4HXoLVNCiknrLcvBtMo/2qcoFbxzZuY5
kcm4RpbhJMhlt8zf19SthfDappa9hukNSBHdXi9a1HlsgDYuMcmiAGrI+GCaBy88
1t4soTJ+3H7cTUmr4UZifZ3dI3PPvai4tQaWGvTLhhKvgrXeCIv12IVxxt9IcY/J
PhnuBMAlf9RONZBn21MNkXxWYyqi0ZIDtBfucVisVCDDJ4GY3/A+rsHNpCmGpdpo
FZ+Zkl7I4PJERC4yo9TqJ/w9Luf1Xsskv2PjrfVukuiYyynnumSdZLKk6YNM6Meb
8tf1AxnytMeXFD7AxjfBsx7fjyjA/GxA7zthpQ1u4Bv2tJO8OuAIYBM4eTDBcSUr
2WtX93BE8Vck1jH4nqd49462Ph1JY9XJ9Kk2nfvwvNBGM9hdY60QhhLCFoEqCTCI
TMMr8NpXeYzhrkiwZfa8ppKqou4ikZKqiShYEzCvRG6XiaVwBRglRPN+J9xEssXk
j0S5r4QD2p0rlDmJCCSWunPDmDmtgMtygOpfS6trlhugO4qJ39DBVmz/1mLwYJ1O
KTPTZVGZC8eKPbqMsAbW
=uE1j
-----END PGP SIGNATURE-----

--=-dVJ5mpU3VEO60x25EnKi--
