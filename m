From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 07/11] net/peak_pcmcia: take msecs_to_jiffies_min into
 use
Date: Wed, 15 May 2013 13:45:07 +0200
Message-ID: <51937543.1050209@pengutronix.de>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com> <1368188011-23661-7-git-send-email-imre.deak@intel.com> <5193518C.3040706@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2TJUVTAIVCKXTNJFHUUVE"
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joe Perches <joe@perches.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Imre Deak <imre.deak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39476 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932306Ab3EOLpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 07:45:19 -0400
In-Reply-To: <5193518C.3040706@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2TJUVTAIVCKXTNJFHUUVE
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/15/2013 11:12 AM, Marc Kleine-Budde wrote:
> On 05/10/2013 02:13 PM, Imre Deak wrote:
>> Use msecs_to_jiffies_min instead of open-coding the same.
>>
>> Signed-off-by: Imre Deak <imre.deak@intel.com>
>=20
> Tnx, applied to linux-can-next/master.

Removed, as requested by Imre:

> The reason is that in that driver I wasn't sure about why +1 was
> added, since the time_after() check already guarantees a minimum wait
> time.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


------enig2TJUVTAIVCKXTNJFHUUVE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGTdUMACgkQjTAFq1RaXHM0ugCgkMVdlkc9AKNezqn1e9MjO3Jw
K7oAoIpohcwjvXgdLjcD27uMzoXkKk5D
=3cb3
-----END PGP SIGNATURE-----

------enig2TJUVTAIVCKXTNJFHUUVE--
