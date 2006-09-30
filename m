From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Fri, 29 Sep 2006 23:00:01 -0400
Message-ID: <200609292300.05886.flamingice@sourmilk.net>
References: <1159435399.2648.17.camel@ux156> <451D8BD1.5020906@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2429544.Q1R4Wdf6yo";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"Luis Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:31706 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1750709AbWI3DBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 23:01:44 -0400
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <451D8BD1.5020906@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2429544.Q1R4Wdf6yo
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 29 September 2006 17:10, James Ketrenos wrote:
> Johannes Berg wrote:
> >  * Should the userspace daemon be allowed to unilaterally update the
> >    regulatory information if it learns something new (via the user)?
>
> Many countries forbid users (root is still a user) being enabled to
> override the parameters set up by the hardware vendor as tested for use
> with a specific device.
>
> If the hardware and/or driver for the hardware advertises a set of
> operating parameters, user space should honor those settings and the
> kernel should enforce them.
>
This makes 802.11d impossible. There are already many ways of violating loc=
al=20
regulations. We should not make it easy to override the regulatory domain=20
parameters, but going out of our way to make it hard is not gonna work.

> With hardware that restricts operation to the capabilities it was tested
> and calibrated for, this will likely result in a broken user experience
> -- if they try and use a device on channel 13 and the device restricts
> operation to channels 1 - 11, tuning operations will fail.
>
So the hardware should not even restrict tuning to channels 1-11, for examp=
le.=20
That sort of enforcement belongs in the kernel, with information imported=20
from userspace so parameters for various regulatory domains can be updated=
=20
easily. (whereas with hardware enforcement, every change requires new=20
firmware) Sure, it's a bit easier for an enthusiastic user to set the TX=20
power too high or tune to channel 14, but it seems likely that the number o=
f=20
people who would do that is a bit smaller than the number of people who=20
travel between different countries frequently (and would benefit from=20
easy/automatic regulatory domain switching).

=2DMichael Wu

--nextPart2429544.Q1R4Wdf6yo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFHd21T3Oqt9AH4aERAs2jAJ9pj770ia6/xApJXHUbrTHJ04O1IQCeOk06
nQFExpH9RVQMMja7liHCuZg=
=qypb
-----END PGP SIGNATURE-----

--nextPart2429544.Q1R4Wdf6yo--
