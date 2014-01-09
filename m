From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Thu, 9 Jan 2014 17:34:18 +0000
Message-ID: <2C8FA848-3185-43BA-BDD7-955B0C7DD835@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
 <1389166847-3780-4-git-send-email-aaron.f.brown@intel.com>
 <CE14B815-C10B-4091-A608-6742117FBEF6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D4C75B04-E46F-44DD-9101-D96951B10622";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19598 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbaAIReU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 12:34:20 -0500
In-Reply-To: <CE14B815-C10B-4091-A608-6742117FBEF6@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_D4C75B04-E46F-44DD-9101-D96951B10622
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 8, 2014, at 12:47 AM, Scott Feldman <sfeldma@cumulusnetworks.com> =
wrote:

>=20
> On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> =
wrote:
>=20
>> From: Mark Rustad <mark.d.rustad@intel.com>
>>=20
>> -#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr =
+ (reg)))
>> +static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 =
value)
>=20
> Bummer, now you have a all-caps func name.

Agreed, but this is actually a fairly common condition among drivers =
that used to use macros. It isn't perfect, but at least it is moving in =
the right direction. I'd rather leave the case change for a later patch =
series that does only that or has some reason to touch all of the =
register access sites.

At least the new accessor I introduced is lower case. :-)

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_D4C75B04-E46F-44DD-9101-D96951B10622
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSzt2ZAAoJEDwO/+eO4+5ux44QAMEbM1u/wkAIjys7wL6whC3M
MVu6DoHwqbpmgFrD19CXmGssCbAnM4LHt0fYCr6HGl20mSvDFdz5u5QqgNgozBwc
DKwDu1ke5KcMsnYJLnY5/EKr8QJo0o5rpzFt/yaIayXeWD5+vhLQhS4UV5VjATOd
ajJs7eNHD6+puekMQ32PgcaVmx+MLhfDsIGRbRnLsSMzZeh4yjppnz09ppSqhq9L
4L/+d8lkDXBKlXy0P6w7wW/RXIcrTs3S7uGR5HUqf1CZkm4+b2sGACivgNiOuTDN
wWNXvpKi8zIWnttLBj+TILGoaXNmrMIkb86VvVKcCCUkaAeTLQxXsvNxXbZ2jtbT
9KM18Xqm2PSFEsDUCiclwUOph1qCfAFeaha1mvBE7l1qycYpCwkcZ652Xi5C/gJ9
OHH7v5ua6sf7KAMF5cWHGoYA1uWWhnhPEI3D3ht1tahzd2hdc8Axp9dUK3z8w0Yh
452lp4zjxdOzEvMoJ0vC7eH5EJmzB/ICQIYnAT659xHmBmFGChLrzBsDgdWFHxix
b9sNGBfuRR15n0Ne8P8Ct4iGWvj2xJpIO0xU8qjLpqr5zcM7jwk6CDjpuKfMw5A5
KNNejLzHM2iGxH+yWT8Qm7xiMs0wnYML1FjP7tKFsmElPINoJO+cBpampbHmyxxy
RcVMVoox0R+sNpZRI0ki
=bQww
-----END PGP SIGNATURE-----

--Apple-Mail=_D4C75B04-E46F-44DD-9101-D96951B10622--
