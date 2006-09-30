From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Fri, 29 Sep 2006 23:14:54 -0400
Message-ID: <200609292314.58266.flamingice@sourmilk.net>
References: <1159435399.2648.17.camel@ux156>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8530002.N430OcHnRt";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:25054 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1750715AbWI3DPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 23:15:44 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159435399.2648.17.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8530002.N430OcHnRt
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 28 September 2006 05:23, Johannes Berg wrote:
>  * why should there be configuration per device? The user can only
>    be operating in one country at a time... I think that information
>    should just be available inside cfg80211 in a global structure
>    for use by drivers whenever they need it (with some accessor
>    methods to ensure locked access).
>
Making regulatory info global is good. We're not really interested in a lap=
top=20
with two wireless adapters sitting on a border.

>  * I seem to have read between the lines that the EEPROM data is
>    pretty much useless. Is that generally true, or should the userspace
>    daemon be told what it contains (somehow)?
>
Even if the EEPROM data is useful, the driver should probably process it=20
before giving it to userspace so we don't have to worry about updating eepr=
om=20
parsing in userspace.

>  * Should the kernel perform some kind of validation on the regulatory
>    data the daemon gives it as well?
>
Probably just minimal sanity checks if needed.

=2DMichael Wu

--nextPart8530002.N430OcHnRt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFHeEyT3Oqt9AH4aERAt5dAKDQkDmMHCthj6XWH65KBFshWMDXwQCeIxUB
Q9KC4NJDWacWtjXDOFye4YU=
=VaSm
-----END PGP SIGNATURE-----

--nextPart8530002.N430OcHnRt--
