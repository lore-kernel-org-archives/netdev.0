From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: increase timeout for ethtool offline
 self-test
Date: Fri, 01 Feb 2013 16:29:03 -0800
Message-ID: <1359764943.14217.33.camel@jtkirshe-mobl>
References: <1359732095-17197-1-git-send-email-sassmann@kpanic.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4EoyHvuW2/TL73UNOw7n"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	carolyn.wyborny@intel.com
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16486 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757323Ab3BBA3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 19:29:04 -0500
In-Reply-To: <1359732095-17197-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4EoyHvuW2/TL73UNOw7n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-02-01 at 16:21 +0100, Stefan Assmann wrote:
> On several machines with i350 adapters the ethtool offline self-test
> sometimes
> fails. This happens because link auto negotiation may take longer than
> the
> timeout of 4 seconds. Increasing the timeout by 1 seconds resolves the
> issue.
>=20
> Output from a failing i350 offline self-test:
> while [ 1 ]; do ethtool -t eth2 offline; done
> The test result is PASS
> The test extra info:
> Register test  (offline)         0
> Eeprom test    (offline)         0
> Interrupt test (offline)         0
> Loopback test  (offline)         0
> Link test   (on/offline)         0
>=20
> The test result is FAIL
> The test extra info:
> Register test  (offline)         0
> Eeprom test    (offline)         0
> Interrupt test (offline)         0
> Loopback test  (offline)         0
> Link test   (on/offline)         1
>=20
> The test result is PASS
> The test extra info:
> Register test  (offline)         0
> Eeprom test    (offline)         0
> Interrupt test (offline)         0
> Loopback test  (offline)         0
> Link test   (on/offline)         0
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)=20

Thanks Stefan, I will add the patch to my queue!

--=-4EoyHvuW2/TL73UNOw7n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRDF3PAAoJEOVv75VaS+3OK7wP/jTK35nVFe+avQxRgGWHRXqY
horR7rohnMOR+Oq6TC7YIddfvvFcFZLmNNf6cNaXQLeotvz+dJSrVDwD+1JDKMLx
R4hmSLkUa3w/M2DLA5LYNwXddIP5KuNQO1VdKIQBwj+VyCvInO0TCZIozpk9v0et
BGWZIl5nQnsn8xXRYqpKGZQI2lmF2b2mAFcFgU7NbcbOzJh5NvJFrrv05pTEmQQG
nrZY+Um4m6c/Z+/1gD67uvoHUXHCoIWLHBgt3Yi3IVHXtmQc57FEpQ1orrZ6UIq/
cI8HrLr/WBT2Sn0SqvRD4ashw43lj5036qBg8LRehBzo95FjccTxd2wfAN0wEPbA
MQflmR0Q1LZNTyHamCPGS8qSxaHceWesNvS8Lw5ow0OCyJPhifVENSyF7fbeQfaB
OW98ofspQBKva7wLjjeIF909kBcgdijGS1tyMZ16bF1rk/nyBY1qzsX6eda0+Pv4
CRrPTcoWRV9sTZabCKjHfRljGS9P+ookXJY2Hos8QulJoAwpqesMR+NbPaSgd+QL
Pf7RntmGaXcMLEbS1WPyyJuTM51fUkZGHbsYnTfTzd39anApeom+AdXIpjySY42B
4f1q5MjkllpKMfyFtlQ3OQJSaCFQkir1d0utod1A/s/CXFDxGo7uEwV8YQIAowr+
qdD8Vkj4r/xGpU9/EXM+
=EtmV
-----END PGP SIGNATURE-----

--=-4EoyHvuW2/TL73UNOw7n--
