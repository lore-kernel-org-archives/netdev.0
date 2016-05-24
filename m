From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 0/2] Follow-ups for GUEoIPv6 patches
Date: Tue, 24 May 2016 10:14:32 -0700
Message-ID: <1464110072.2631.13.camel@intel.com>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
	 <1463606878.2713.68.camel@intel.com>
	 <20160518.211043.773402183440053556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hf3+QYiNU+uYzQpR39ht"
Cc: aduyck@mirantis.com, tom@herbertland.com,
	alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49202 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769AbcEXROr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 13:14:47 -0400
In-Reply-To: <20160518.211043.773402183440053556.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hf3+QYiNU+uYzQpR39ht
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-18 at 21:10 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 18 May 2016 14:27:58 -0700
>=20
> > On Wed, 2016-05-18 at 10:44 -0700, Alexander Duyck wrote:
> >> This patch series is meant to be applied after:
> >> [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v6
> >> tunneling
> >>=C2=A0
> >> The first patch addresses an issue we already resolved in the GREv4
> and
> >> is
> >> now present in GREv6 with the introduction of FOU/GUE for IPv6 based
> GRE
> >> tunnels.
> >>=C2=A0
> >> The second patch goes through and enables IPv6 tunnel offloads for the
> >> Intel
> >> NICs that already support the IPv4 based IP-in-IP tunnel offloads.=C2=
=A0 I
> >> have
> >> only done a bit of touch testing but have seen ~20 Gb/s over an i40e
> >> interface using a v4-in-v6 tunnel, and I have verified IPv6 GRE is
> still
> >> passing traffic at around the same rate.=C2=A0 I plan to do further te=
sting
> >> but
> >> with these patches present it should enable a wider audience to be
> able
> >> to
> >> test the new features introduced in Tom's patchset with hardware
> >> offloads.
> >>=C2=A0
> >> ---
> >>=C2=A0
> >> Alexander Duyck (2):
> >> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ip6_gre: Do not allow segmentation offl=
oads GRE_CSUM is enabled
> >> with FOU/GUE
> >> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 intel: Add support for IPv6 IP-in-IP of=
fload
> >=C2=A0
> > Dave, I have this series added to my queue.
>=20
> Why would you if it depends upon Tom's series, as mentioned above, which
> isn't even in my tree yet?

I was not able to apply his patches to my dev-queue due to conflicts and
from discussion with Alex, I made the mistake in assuming the issues I saw
was because it did not have Tom's driver changes.
--=-hf3+QYiNU+uYzQpR39ht
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXRIv4AAoJEOVv75VaS+3Ory4P/AjSaguGw9xt5bKo4kxp5mxo
j/n8vYjo/3PjW/TPZ37A3LRI7t8jEhZYDRbGhtlJG+bodqtr/0KuNRoAgJzMRMuX
SL7P4dXLwgLcVqyBxSE2uw9cyphXUbKDKSv8Hsxchl5wrPtEp67edRN7/idboRTv
MKl0vrzucuhhvRwaia84Nh0YzXLiUVgX80HDYn4PH4pCCybPo/Tbj/Agwr2N20SR
F3o4VA5wPwIQ+Q7f2F45R2uSAkIQipATE30JSAKgRRWkpQVollHULlMw319P3hkL
+rsyx6GKK/KXLgQgc8cfST2xTpudvSLTnrHoPbY+nv9wJbUPBb7VSK3SkLdFi8a9
mSUBQbEFZNbcVDvwlqp506qRVvXdwKPnh96PjuDGPAkuFle9wvvqnEEX52wQg5da
04aPgar4RgHN08CFnzwoU8La2rAfgKnBNlcvP+myH9+uyCP0eQDN3AFyP0d35wzT
8YG8jdtW+SJwLrrKiKussBczd8nfq43kQ+cJfMIuS2diY1wDle8iGu1CE1R4r9db
3ByHZadGGPkbzUSACde27iirNFUUQ7Ja8PdtIAprC1o9w4lE/Ckt/SlAUsaGcDBN
pXIIL4VxXDMtWMPC2NFisR6olGn1SmdgQ69uzgJe/ZFtCUTyF1Tp9h/Twg9ME/jr
HT5+h+mS1foLGlv654Ok
=4vek
-----END PGP SIGNATURE-----

--=-hf3+QYiNU+uYzQpR39ht--
