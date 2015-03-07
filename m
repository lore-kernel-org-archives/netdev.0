From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCHv5 net-next 3/4] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Sat, 07 Mar 2015 18:02:53 +0000
Message-ID: <1425751373.4027.15.camel@decadent.org.uk>
References: <1425611905-28503-1-git-send-email-fan.du@intel.com>
	 <1425611905-28503-4-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lmYBQeauK7kr08HflcRz"
Cc: jheffner@psc.edu, davem@davemloft.net, edumazet@google.com,
	netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53557 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbbCGSDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 13:03:14 -0500
In-Reply-To: <1425611905-28503-4-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lmYBQeauK7kr08HflcRz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-06 at 11:18 +0800, Fan Du wrote:
[...]
> +	/* When misfortune happens, we are reprobing actively,
> +	 * and then reprobe timer has expired. We stick with current
> +	 * probing process by not resetting search range to its orignal.
> +	 */
>  	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
> -	    interval < max(1, net->ipv4.sysctl_tcp_probe_threshold)) {
> -		/* TODO: set timer for probe_converge_event */
> +		interval < net->ipv4.sysctl_tcp_probe_threshold) {
[...]

Did you mean to remove the max() there?

It might be better to enforce a minimum value when the sysctl is set,
anyway.

Ben.

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-lmYBQeauK7kr08HflcRz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVPs9Uue/yOyVhhEJAQpWWxAAsOxhwTd5iowUlNNqMBmjid/YKvUAhGS4
63PfR5ySAvLsbCntgpWbFL3tGidHteH4iYY3kH/nLXtinQyGo8hciZ2Qa5WXXE7v
6bwtwJY/7PO/0ZgrkziTonq9cLsl1FynxAgLbzGuFmg3dDW+141rHKxHLOsFZjIx
5t/qdylD6pSZ8GVAxNlzNkuHtV4GwJC+oz0QzJYFvN/CgHzAiWA/y1QhLFmhvSA2
WdXDcCIjEkavM6O1DU9QNcwTAbco91s5pxaheUiH16DSAXh9e/TNBLsIs85ewchw
/9pFXcy5FqjqdjyuJmMHFjJkpdXmkEBnOamOsbGFUJkOuyXvlD2rWYLEA7HQ5ocQ
GwbCl04R/g0AZ6oBabJdjV+yivVRR3OQC26g7puTSbFJ+ZpBQV0wKsscKJtZmgLO
C0RkwdVa6+8ufsga2BY1cKvG3WQIL1dZ3RX+hN2U275S39gV3qwNvsgn0DDiNc4H
fkwWaG9ZqTKEhj9XieELyAp2L9zV2pRZ56ghPiWpF2B0fnEgr/JqAz+9hCTVXKZz
QnAjsjWw5ZjpHs+M3QlJ2DpPl0pWF5cMXP3aEFbPR1nUff1KgRUlzo9CAcXnB1ZH
kDCVcCnHP9PKUgMAe9cOdEpXAcX/9AMEowu3JQPz+v/N4dHq0jWxDJQ04d8J/so2
msZhnO7lrkM=
=3+H6
-----END PGP SIGNATURE-----

--=-lmYBQeauK7kr08HflcRz--
