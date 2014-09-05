From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: Compilation error on freshly pulled net-next?
Date: Fri, 5 Sep 2014 22:21:43 +0000
Message-ID: <F30331BD-6C7F-418B-972F-6C4FD2E7D33A@intel.com>
References: <540A2F7F.8060809@hp.com>
 <20140905.150901.79089716373802484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_125D2654-DF85-4A4D-AAD8-8DEAE3A7DE59";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "rick.jones2@hp.com" <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39203 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980AbaIEWWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 18:22:07 -0400
In-Reply-To: <20140905.150901.79089716373802484.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_125D2654-DF85-4A4D-AAD8-8DEAE3A7DE59
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Sep 5, 2014, at 3:09 PM, David Miller <davem@davemloft.net> wrote:

> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 05 Sep 2014 14:47:43 -0700
>=20
>> Looks like someone slipped a J in there and confused things:
>>=20
>>               + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS =
+
>>               IFLA_PORT_SELF */J + rtnl_link_get_size(dev) /* =
IFLA_LINKINFO */
>>               + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
>>=20
>> (hopefully my mail client won't have mangled things too badly)
>>=20
>> What is odd though is a git diff after I've replaced that 'J' with a
>> return isn't giving me any output.
>=20
> That doesn't exist in my tree.

Looks like data corruption to me. There is a one-bit difference between =
line-feed and J. Oh for more ECC-capable systems...

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_125D2654-DF85-4A4D-AAD8-8DEAE3A7DE59
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJUCjd3AAoJEDwO/+eO4+5u/qIP/2ZPAsaV5PSJu6UCtgW8wPjc
a3avSnMPlJo7FjqtxOVigFaNUJ5vMd4K8XFz9fQUbVjyTcbYVw5uVdlHWsOQvvLr
qkPzUEDafLx5i2SiW+A9tCaAfG0KmMX4eMBrZcmkLLFq7ifZjmBU0XW4Df51Kz8H
GgdLEeTgZEYmUXHidorCkxlZa687DBWbXg2Rxe6xxDCnpBzLCRpWKf9xUGJTOxJv
g2czHbTKGSh8CIdSzNCLGfFtwPdTh0LWyIhsuAcqWKuWDNbJxzWTrGwp2aWAFI9q
cUjeZHAV320gr24hSfm7uRem7qSqRTXbW96UoKOI0uozhNbZ0Z+3swyGAh4qjsa6
MhYd6gKt0jqB5axmwreWeU1JKlILSQ3r22agh4Hj0IXwuTvXg5OG9v0uBBrDkwjK
PrBnS6EZko9PqfiOhaNcHLCYeQlmlwsk0jL2c5HNDRSx515fQil1IZCTOjL1nger
eVRbwVNvJhHnn9NdSstV0WOVtd/KHHighUjMKc7iXhfDkLo5agBpP2wqmCjQPxDw
9EqVyls4TF+XvspQzb/QkTIN9Ebr5y/eOWQcO3BUqEAW/xhMsLNebld5FCfSLbQt
woNZyoqVrvMSNFuRsh+phoMZnAdb7jGdJNtIEvsnZn83uduBRrrzwMJk4c0pI5Tf
uyJmMzbtFnZTL3vLe+OZ
=deNM
-----END PGP SIGNATURE-----

--Apple-Mail=_125D2654-DF85-4A4D-AAD8-8DEAE3A7DE59--
