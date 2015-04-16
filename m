From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 03/14] i40e: Add support to program FDir SB rules for
 VF from PF through ethtool
Date: Wed, 15 Apr 2015 18:42:36 -0700
Message-ID: <1429148556.2638.72.camel@jtkirshe-mobl>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1429073511-27664-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJ3xEMiKw2DBWhF5UQZ8yfCpPKAMuyZk18sQm9Z=QgPhG_DPqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TuzeGC8dqdMDO/lP0OA9"
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Matan Barak <matanb@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28787 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbbDPBmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 21:42:39 -0400
In-Reply-To: <CAJ3xEMiKw2DBWhF5UQZ8yfCpPKAMuyZk18sQm9Z=QgPhG_DPqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TuzeGC8dqdMDO/lP0OA9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-15 at 11:58 +0300, Or Gerlitz wrote:
> On Wed, Apr 15, 2015 at 7:51 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Anjali Singhai Jain <anjali.singhai@intel.com>
>=20
> > With this patch we can now add Flow director Sideband rules for a VF
> from
> > it's PF. Here is an example on how it can be done when VF id =3D 5 and
> > queue =3D 2:
> >
> > "ethtool -N ethx flow-type udp4 src-ip x.x.x.x dst-ip y.y.y.y
> src-port p1 dst-port p2 action 2 user-def 5"
> >
> > User-def specifies VF id and action specifies queue.
>=20
> Hi Jeff,
>=20
> We're too eager to have support for PF controlled ACL / over-ruling VF
> traffic.
>=20
> I don't think the way to go here is just go an use the user-defined
> "data" field of struct ethtool_flow_ext to represent a VF -- since VF
> is well defined multiple vendor supported construct. At least in the
> command line would be better to see "vf 5" and not "user-def 5" -- and
> maybe also down into the user-kernel API somehow enhance the ethtool
> flow related structures such that VF ID is specified?

Thanks for the feedback Or, I will work with Anajali and Jesse to get
your suggestions implemented in follow-on patches.

--=-TuzeGC8dqdMDO/lP0OA9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVLxOMAAoJEOVv75VaS+3OgVMP/0qRdJoX1UHgVThUtw4uR5ie
YejMbk0Bct7ZGQ3R8dh43xUDpnryL0weZV6UuQUPpHTO7umxHvRtQfDo3SU21ajn
CkjCY9ilUYfw1wLqijVLAkW44TOVFSqn0Puctvz2goN18kSvHYCZwUurBfN+DFZy
0xesOJm9IG61pFwLBOZ7GFyslNKSfcpWEII8zyQHB3u+uKLXtL43ZnUAg+wjOhAC
guw6nJBMZ0SeQPmz8puRKDH4QSIi2tcfHiNJOMcFwbV1XbbJlQFOULpkBXI2Mi1y
onrRwXX8rqqAldeAfCdvhPKiOJzOpRBGsTnueUKICYOhz2sqX4jLcknxdlvxnOk+
zDKJA5R62OO8ZItoOUWcuDggYSaqKKGEoL39CvSVtRx/lg8iTIxD7kazc7PlOaY0
gqZot5MawPE0oozUVnJWdd59ReW6LhyBNBz7NergLQtil3mO1an41vl3UHNc/g3b
iaTy1ZSJHpAvyDZxCs6fWJ1lr2Picw5vZMjDgc06aKF5fc6Fqk+4y13T5mfmBSqx
+7XXxB8154vB7kti6IEPM+1sz7smwws8oO0VSbZhWOIBakNaz6iu/M/AWS/s+BKi
xB+TPzGviRcfcsxA79H0phShuRKCFP1Ql6s/tr9Gq8YadnA/o5V7YjkFREsIbJuM
7vhqggtybXpnRINOrkrQ
=1p1U
-----END PGP SIGNATURE-----

--=-TuzeGC8dqdMDO/lP0OA9--
