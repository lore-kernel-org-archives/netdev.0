From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 2/3] if_link: Add VF multicast
	promiscuous control
Date: Wed, 08 Apr 2015 13:43:39 -0700
Message-ID: <1428525819.2579.7.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CD61@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1910483274122827636=="
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>, Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CD61@BPXM14GP.gisp.nec.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1910483274122827636==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RNNEOLmoKAh1MEGg6wEv"


--=-RNNEOLmoKAh1MEGg6wEv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 05:37 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Add netlink directives and ndo entry to allow VF multicast promiscuous
> mode.
>=20
> This controls the permission to enter VF multicast promiscuous mode.
> The administrator will dedicatedly allow multicast promiscuous per VF.
>=20
> When the VF is under multicast promiscuous mode, all multicast packets
> are
> sent to the VF.
>=20
> Don't allow VF multicast promiscuous if the VM isn't fully trusted.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  include/linux/if_link.h      |  1 +
>  include/linux/netdevice.h    |  3 +++
>  include/uapi/linux/if_link.h |  6 ++++++
>  net/core/rtnetlink.c         | 19 +++++++++++++++++--
>  4 files changed, 27 insertions(+), 2 deletions(-)

I will add this to my queue, thanks Hiroshi.

--=-RNNEOLmoKAh1MEGg6wEv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJZL7AAoJEOVv75VaS+3OU74P/RwRfF/QWyp5/Okgc7i/xzbB
UhvdjR2Drk/V6UsQ15tQkMT/GO56z2jLbqriFyHrO1cZPQ/NGrAiu4s0ZD3xiueJ
xyW7fAHKFk01BIGQ6u2hyoDSB+v2aH8wzPACx6EbrzfII18Lx7sCFt8o2lbRdm73
tyge6WIC2bsA46snODo7OTm1aidNi1Ebzs+DIfKjW1yAX6ntmeLIIQb6rw2cBXsu
9DUCUg4cAlAuD61e/N6Mpa9uw7Pf6OFzES+cbuerlEDYLMGd41XAbrgyOWCjyDAP
6FXDadXcqwRWhROksoqFsUHuvILjIsS7NINRbN1Q3aLW7RPMnD6BKRVZbBnFBStQ
XAS1Qqj0JutpCCQxFVu9SCIgK+hfVq1UQ7h1e5sLKae2hKCdsJEVTD5IA7uNNCmr
cOBiGs/Cf0zYCVsVyNf4oM0ei9GJHV8wb9LhMN2kbVtiPf7LntFOEL4laroPyBZ9
2eUH155MJ9zY4H3qqvR32zm0Kh+dSwjUprtWqxZySS9te1fkqXJbfC7L8O2Uuns+
GBkXiljIzq9Pf2r2oVxsqsFPVuHkC9hs3SVh3lpkIH89JLjztZKcpssiGgDq0dGp
mJ/nd8911etna55FGE6flMhwK0j80pYI1jnm3fGR6i68VRvEyLI5gNZ6aIKbcwn2
KtFNxx8ntown4Fup48td
=uDVi
-----END PGP SIGNATURE-----

--=-RNNEOLmoKAh1MEGg6wEv--



--===============1910483274122827636==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
BPM Camp - Free Virtual Workshop May 6th at 10am PDT/1PM EDT
Develop your own process in accordance with the BPMN 2 standard
Learn Process modeling best practices with Bonita BPM through live exercises
http://www.bonitasoft.com/be-part-of-it/events/bpm-camp-virtual- event?utm_
source=Sourceforge_BPM_Camp_5_6_15&utm_medium=email&utm_campaign=VA_SF
--===============1910483274122827636==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1910483274122827636==--
