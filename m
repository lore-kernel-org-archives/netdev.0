From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 04/14] ixgbe: remove CIAA/D register reads from bad
 VF check
Date: Fri, 05 Dec 2014 20:58:12 -0800
Message-ID: <1417841892.2399.2.camel@jtkirshe-mobl>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1417801973-28793-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20141205.204956.1468623374943582606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pN2R9Aw2QSxmU15mlOFG"
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	alex.williamson@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13729 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbaLFE6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 23:58:14 -0500
In-Reply-To: <20141205.204956.1468623374943582606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pN2R9Aw2QSxmU15mlOFG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-12-05 at 20:49 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri,  5 Dec 2014 09:52:43 -0800
>=20
> > From: Emil Tantilov <emil.s.tantilov@intel.com>
> >=20
> > Accessing the CIAA/D register can block access to the PCI config space.
> >=20
> > This patch removes the read/write operations to the CIAA/D registers
> > and makes use of standard kernel functions for accessing the PCI config
> > space.
> >=20
> > In addition it moves ixgbevf_check_for_bad_vf() into the watchdog subta=
sk
> > which reduces the frequency of the checks.
> >=20
> > CC: Alex Williamson <alex.williamson@redhat.com>
> > Reported-by: Alex Williamson <alex.williamson@redhat.com>
> > Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Alex Willaimson stated that he'd like to see this for -stable, but I'm wa=
rning
> right now that a change not appropriate for 'net' is not approperiate for
> '-stable' either.

Agreed, only reason I did not send this to net (along with the other
fixes by Emil) was that we are at -rc7 and do not consider these
"critical" to try and squeeze in before the release.

--=-pN2R9Aw2QSxmU15mlOFG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUgozkAAoJEOVv75VaS+3OXT8P/0Yu7L8Wv5GH01ck9A09hmwL
9Dp0r3uZVPGzT6Rrqsz2etvC/bLszRVurYRSjwdVnamEKNK/HVT2hmVS7AEEXUAO
+31jg3G/4N3ZFsJBFU65m/hCDYPZGIZvHAozZQ7K1pwuDNQYBtL4lGhK4L4VTa5K
dFlcpDtsF15iYXUNEmw6v+hrn7abdgVnDzmu1HHupTqdHJq+z8WonBgSASfEEeK2
+gqHyD0lMWeuda6cU4TMchzp/aC8Fhgc7I5T5TLASDEf17DU7pXIOSfrt76f5Y35
l1TKCm5QFsghTs7r2WLh1DXcCZEn59L/DzfMbJvCpEU65fXVpVB3AZw1buMDpwcQ
6y3pLqzXOcq/xKHEDt37mMeUzbd6sEdo6ArrwSs2eP6/E38iKD/oYxOB0XWZx3Z/
JAn8jmBal/Ysh4eUnmehwKVHnkiFWAhSOarL/7F8e9oc7SzsAhzF0AwkSlRA/0tJ
TEt7Gw/ypVYVWJfZCEHs3ih8JNORFDhsCydXNWHm0Uw0EMT1sD1qkrjhbP12SJRI
FnTECBbJW/RSofWHEr2y3SOE2iLbmMKy8AT4ETKE+5CQwecymqqiOXygLn2gBQmT
JNKfa5yElC/asj6UG87+tKkFrrBrrSz5NLOELP9T8MGqdT4lDnLrMMirqqOjrpka
eqn1FP9KpHWZ1c4iAgPI
=zt/4
-----END PGP SIGNATURE-----

--=-pN2R9Aw2QSxmU15mlOFG--
