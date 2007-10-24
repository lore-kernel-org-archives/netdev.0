From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: on the topic of alternate MAC addresses
Date: Wed, 24 Oct 2007 11:28:20 +0200
Message-ID: <1193218100.5715.14.camel@johannes.berg>
References: <20071023.180534.59659315.davem@davemloft.net>
	 <471EAD01.5030502@garzik.org>
	 <20071023.202210.74747025.davem@davemloft.net>
	 (sfid-20071024_042230_590516_A46C28C9)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3yTUIHP0DhNnYtRE1cH0"
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35073 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbXJXJ1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 05:27:01 -0400
In-Reply-To: <20071023.202210.74747025.davem@davemloft.net> (sfid-20071024_042230_590516_A46C28C9)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3yTUIHP0DhNnYtRE1cH0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-23 at 20:22 -0700, David Miller wrote:

> However, it's not the virt clients that do this, it's the control
> node (aka: domain 0) which has to manage these things.
>=20
> It has to manage all of the global hardware resources and allocate
> them out to itself and the clients anyways.
>=20
> And this is why I think it's sufficient to just publish the list of
> MAC addresses from the driver, and leave the allocation and policy
> to the userland virtualizatin daemon running on the control node.

=46rom a wireless angle, however, it's not sufficient. It appears that
there are some wireless cards that have multiple MAC addresses in their
EEPROM (or a way to generate multiple, by e.g. the vendor assigning only
even addresses and reserving odd ones). Then, bringing up a second,
third, ... virtual wireless interface should for best usability choose
an alternate address if the same one cannot be used due to restrictions.

We can probably manage this issue in userspace, in fact, for AP mode we
require proper configuration in hostapd, but it seems that some sort of
reservation system would be easier for multiple virtual station
interfaces when supported (currently no driver does).

johannes

--=-3yTUIHP0DhNnYtRE1cH0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARx8QM6Vg1VMiehFYAQJGUBAAjmjnM+xyC2DpgTnMGO41fJB8APn/JgAF
GrjP5honPuHnbEMJVA695EGJRXP0cF74/ZL/bnPgslygwDzusLHr+RK8AjCaaNlh
ShAE7T2shjHAPMfj7B2mxBD4eQz5hCsaFREczGAhfUjsnNXgMP1vQeZ84KWvlww5
pICMFEUWzNnDMFu04a2tr3t6cg3QQpbYcLaMebl2ARIid4TOvc+mpEEtLYwPp4lh
Dk/es9ZcvgjqV5YjAZBBLiL5imNqG/dd/ckoSP2oLgwc8UzkruXbrgtrMzisXjE7
je9BvfYIr7S/WmwEmSfC76uTAMZdhmiuKTjp4K2/mYlryZyAaot6YtpsZs+MC1mH
MS+kFv/U/XaHrm1oSLrWSn3dVfcvtM6PjjibeSLKoRAb9ukT9ujsosUqA7/RI6ck
imxt8vG865jVw6BhWhPnHVEv7Lb1cA7+3SdALBEYy4in5yH6+Dt6/kFM2ZMMV3+j
r1RS2FW15I21TzWQj5M0mcdUYrcGG13UL3ZsLTLaYk9fuoVoJum7vOlHsN7ow4Ah
LkXvLGayRHHE6obm0FDgT5WdU9pReAH5cbpuqmEjAdnRI7qDXKsCydEKXZEKiGNh
ywASFnOeyRs+NqOfUqROqiCYsiMkMsxg9vXwJaYK2F5QmOF5tPIqTwcJ9sPECM8o
/N7/AgOv6wE=
=NLyK
-----END PGP SIGNATURE-----

--=-3yTUIHP0DhNnYtRE1cH0--

