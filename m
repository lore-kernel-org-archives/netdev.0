From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 3/3] ixgbe: Add new ndo to allow VF
 multicast promiscuous mode
Date: Wed, 08 Apr 2015 13:44:02 -0700
Message-ID: <1428525842.2579.8.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8265455703585491039=="
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
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CDA0@BPXM14GP.gisp.nec.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============8265455703585491039==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-B9bPgW9AEfyHO2EB5C9L"


--=-B9bPgW9AEfyHO2EB5C9L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 05:38 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Implements the new netdev op to allow VF multicast promiscuous mode.
>=20
> The multicast promiscuous mode is not allowed for all VFs by default.
>=20
> The administrator can allow to VF multicast promiscuous mode for only
> trusted VM. After allowing multicast promiscuous mode from the host,
> we can use over 30 IPv6 addresses on VM.
>  # ip link set dev eth0 vf 1 mc_promisc on
>=20
> When disallowing multicast promiscuous mode, ixgbevf can only handle
> 30
> IPv6 addresses at most.
>  # ip link set dev eth0 vf 1 mc_promisc off
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 32
> ++++++++++++++++++++++++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
>  4 files changed, 40 insertions(+), 2 deletions(-)

I will add this to my queue, thanks Hiroshi.

--=-B9bPgW9AEfyHO2EB5C9L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJZMSAAoJEOVv75VaS+3O6W8P/iM9xck42HUzc29sf547hyQ4
+XJzRdCCxdOI/tVtazjGdjMEvGEziDZPh53OcNcb62tEMQ5oRdFy2RbeLKUNe73O
gOApm11V1f1NzPUyPqFiKCXizAC3P4efrxE2iaxGdO85Ob8+doO22RYZmXTvgPrZ
cmg8PyVZVh6ipGTPYGnagO2NbfEtVsNW4y28I01PpDy6VvsGGR6Pn8ra2skxpFGU
6AmzOgMgEUxe2HNtYGHxXRvgSyvlOsiXDbCIjiT08a37h4fs5GhFRNXSe4j+iI7l
3UGhHY0kgP+Is2xRYxW9EUs/ewq5LqkEwqFd43qDzbY5Yw64f28oPsvt3gY9Ako1
ZS2yS6bnbzERd0B3SVEdulCkd1lzWmuJ8Gc2M+n2OMTaosTXEZuh3q4Y+H6dgrMz
IgbBoa7mWdLhsyVlqJr7/FO+530mLmQy0eppsLN3wBiJ0vFD3TKNlRDw11vW7VCd
esxwh1pP8HfoqVo+023QPhL1alhVkABUUjN08o5IkW1IY+9XTYfe1EFNHEW/FqUf
o70rqbKQR2lvWJntLHqQ7cTSv3PR7Gcgj8P4RnjxQxkKOqFdoryy5DJY91r025m5
W46L+Jg4Evhr+2B1MCGvDZqS5N+L+vl7jseJKd6eCvjnMTcyxwM7METHjvmZHrzX
hDC/T9WlekYhjaWW1iTD
=mQJw
-----END PGP SIGNATURE-----

--=-B9bPgW9AEfyHO2EB5C9L--



--===============8265455703585491039==
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
--===============8265455703585491039==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============8265455703585491039==--
