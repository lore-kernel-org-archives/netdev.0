From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool 2/2] ethtool: allow setting MDI-X state
Date: Thu, 06 Sep 2012 13:57:32 -0700
Message-ID: <1346965052.2284.4.camel@jtkirshe-mobl>
References: <1345538236-1636-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345538236-1636-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1346955923.2714.26.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yn+wXAuD70R3vHaIe7gN"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:18295 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab2IFU5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 16:57:34 -0400
In-Reply-To: <1346955923.2714.26.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yn+wXAuD70R3vHaIe7gN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-09-06 at 19:25 +0100, Ben Hutchings wrote:
> On Tue, 2012-08-21 at 01:37 -0700, Jeff Kirsher wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >=20
> > A bit ago ethtool added support for reading MDI-X state, this
> > patch finishes the implementation, adding the complementary write
> > command.
> [...]
>=20
> Applied.  I also commited the following changes:
>=20
> ---
> Subject: ethtool.8: Mark-up mdix arguments properly
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  ethtool.8.in |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
>=20
> diff --git a/ethtool.8.in b/ethtool.8.in
> index 3208d38..2799e25 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -523,11 +523,12 @@ Sets full or half duplex mode.
>  Selects device port.
>  .TP
>  .A3 mdix auto on off
> -Selects MDI-X mode for port. May be used to override the automatic detec=
tion
> -feature of most adapters.  Auto means automatic detection of MDI status,=
 on
> -forces MDI-X (crossover) mode, while off means MDI (straight through) mo=
de.
> -The driver should guarantee that this command takes effect immediately, =
and
> -if necessary may reset the link to cause the change to take effect.
> +Selects MDI-X mode for port. May be used to override the automatic
> +detection feature of most adapters. An argument of \fBauto\fR means
> +automatic detection of MDI status, \fBon\fR forces MDI-X (crossover)
> +mode, while \fBoff\fR means MDI (straight through) mode.  The driver
> +should guarantee that this command takes effect immediately, and if
> +necessary may reset the link to cause the change to take effect.
>  .TP
>  .A2 autoneg on off
>  Specifies whether autonegotiation should be enabled. Autonegotiation=20
> ---
> Subject: test-cmdline: Test -s mdix keyword
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  test-cmdline.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/test-cmdline.c b/test-cmdline.c
> index 6a60ed4..85b4ce0 100644
> --- a/test-cmdline.c
> +++ b/test-cmdline.c
> @@ -22,12 +22,14 @@ static struct test_case {
>  	{ 1, "16_char_devname!" },
>  	/* Argument parsing for -s is specialised */
>  	{ 0, "-s devname" },
> -	{ 0, "--change devname speed 100 duplex half" },
> +	{ 0, "--change devname speed 100 duplex half mdix auto" },
>  	{ 1, "-s devname speed foo" },
>  	{ 1, "--change devname speed" },
>  	{ 0, "-s devname duplex half" },
>  	{ 1, "--change devname duplex foo" },
>  	{ 1, "-s devname duplex" },
> +	{ 1, "--change devname mdix foo" },
> +	{ 1, "-s devname mdix" },
>  	{ 0, "--change devname port tp" },
>  	{ 1, "-s devname port foo" },
>  	{ 1, "--change devname port" },
> ---
>=20
> Please include at least basic test cases like this for any new feature.
> I did it this time because I've already kept you waiting and didn't
> think it would be fair to request changes.
>=20
> Ben.
>=20

Thanks Ben, I will make sure that we cover that with any new features
going forward.

--=-yn+wXAuD70R3vHaIe7gN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQSQ48AAoJEOVv75VaS+3OOhsP/ihiHiQNxnHDwaEp7pAop+8M
naJnh4Ai4ZaTrGPAcpAxEjLCZHfoaU7UQmj6rBRq2CX2cjA786aDXjrTzAHmgUZv
26Dg2dIWmrwOb/jgwtE1EvuCwZ9kbS8V5Om5dv/Z3hTT5sDXYT1Nj1G+IiwVHp09
9foBSTesSepfE9kd+R1u9XMcqOq/TaBMV90EcIL8ZQE/sopRhZxNJ9o3GFliIu/d
fuC2BBF301Vzz1vJ/2+grZzTV9gfzm7MM0R0RcMGSASqRVNNy8QO7upcaejSZi9r
G7z2nFkPcrC8MyvdixOvBUtB5hkAsmcDfv/cn52GIgswjCi74XjVEkwQYSE2yjZ5
zrtVWgqETX2wKLB6rnewJsh/U3sebqaS0dqqarNqH9JsjRYXvU4pGfjVT5OBy4p9
6F0aS7aeAA2ThmMZP3+/PMIS5I4GJCKWcw/fzbtsRqVZEqG+z6H75Q+XVCkNasZL
1xM/0kx5f5NJSnkRmD3zpEU89kCl9lMQIslkjsPHZcbJPBrcKmCGV+5t1WC118HC
3I24tXoHldQMQCRhrdxcJV6hBO+pxUgX1wiTKlEVH8TUvglr7nu07GcEfISX5Uit
xzeW7KqQaTO44bfwBV04mMfDmeeigFn+NH9yTFfdJrQ9BMUVE61fUp167U7dW1Bi
+zrt8/cIeWLOKm8OyPuV
=AS2Q
-----END PGP SIGNATURE-----

--=-yn+wXAuD70R3vHaIe7gN--
