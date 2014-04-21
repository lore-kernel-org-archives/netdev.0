From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: fix a typo in displaying channel parameters
Date: Mon, 21 Apr 2014 22:36:07 +0100
Message-ID: <1398116167.3624.157.camel@deadeye.wl.decadent.org.uk>
References: <1397785199-1470-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0JFz7sygfQ9jqjFWDPtK"
Cc: netdev@vger.kernel.org, bwh@kernel.org
To: Amos Kong <akong@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51233 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754493AbaDUVgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 17:36:13 -0400
In-Reply-To: <1397785199-1470-1-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0JFz7sygfQ9jqjFWDPtK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-04-18 at 09:39 +0800, Amos Kong wrote:
>  # ethtool -L eth0 combined 1
>  combined unmodified, ignoring
>  no channel parameters changed, aborting
>  current values: tx 0 rx 0 other 0combined 1
>                                 ^^^^
>=20
> Signed-off-by: Amos Kong <akong@redhat.com>
> ---
>  ethtool.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index acb4397..4c75653 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1764,7 +1764,7 @@ static int do_schannels(struct cmd_context *ctx)
>  	if (!changed) {
>  		fprintf(stderr, "no channel parameters changed, aborting\n");
>  		fprintf(stderr, "current values: tx %u rx %u other %u"
> -			"combined %u\n", echannels.rx_count,
> +			" combined %u\n", echannels.rx_count,
>  			echannels.tx_count, echannels.other_count,
>  			echannels.combined_count);
>  		return 1;

Applied, thanks.

Ben.

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-0JFz7sygfQ9jqjFWDPtK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1WPR+e/yOyVhhEJAQpVExAAxNCmPl2hMg81KxkNLIZp6CEbEZZldHEg
Jkho3CvlVMVHK1WDuByZo0E44ATnlxxLwtmzRTLkxt6XbmewwolTszwZ8QQBK7S0
pYEO8ZVq1mNInFaEDhRLhyLjXyh89m6plRynvC/aadmc0EIcFO7GyW2cPehbY1Yg
wLPw5ee6yy3bmEv886GwcLj/BSad5cFb+DBAB0IVnHQUS5QrCH24ok3Kmbblpy8K
WLTINPAyc3Qy7j6dFq6/hJ8bGJbm7Jo17xCGkUqbuOFfRD2JJ2MuAhQXk+wlTmws
jR1/xGns1+g1/DSe0Lx1MFLawxf+V6rO/ALK9zW0DKtqgw42lOuwhIoSa+m8oqhm
PFPPjKjeftukCsmwcJqGP/aoTP1/FPrA4073SXOiWWSnnDybKBK3/ghIi+sIsb+V
MHZ6CmYIM6oqzdxDeKHrxciqvSbFuswfoJEtxLD1F7QaevdMiVrW7vd8rh27C+0u
jR1GMIfN9vxwWR72Mmq97vzCZIr3P9PAsdCfBmkhMGG/qLSyegmD/KzyNcKnTpx/
wTz5OGwEFWAP0rb8n3G0Vovelb1JVe3qz6oIOXOT/BxD7WhOgzvFH1F+xb4GbKW4
4NlRdeszoe2L2VW3yuq+mlcMadj6MYQOwszrJ6eEfHW/CUPzGitO8RQR5xmgSZhd
/QvJHjyel2Q=
=l/5i
-----END PGP SIGNATURE-----

--=-0JFz7sygfQ9jqjFWDPtK--
