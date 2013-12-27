From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2 v2] ixgbe: define
 IXGBE_MAX_VFS_DRV_LIMIT macro and cleanup const 63
Date: Fri, 27 Dec 2013 01:02:46 -0800
Message-ID: <1388134966.2183.144.camel@jtkirshe-mobl>
References: <1387901568-1762-1-git-send-email-ethan.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3575780067708992377=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Ethan Zhao <ethan.kernel@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1387901568-1762-1-git-send-email-ethan.kernel@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3575780067708992377==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jh2BxjmrGP0CuANpMEfl"


--=-Jh2BxjmrGP0CuANpMEfl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-12-25 at 00:12 +0800, Ethan Zhao wrote:
> Because ixgbe driver limit the max number of VF functions could be
> enabled
> to 63, so define one macro IXGBE_MAX_VFS_DRV_LIMIT and cleanup the
> const 63
> in code.
>=20
> v2: fix a typo.
>=20
> Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 5 +++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 5 +++++
>  3 files changed, 10 insertions(+), 4 deletions(-)

Added to my queue, thanks Ethan!

--=-Jh2BxjmrGP0CuANpMEfl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSvUI2AAoJEOVv75VaS+3OiqoQAJOwj6KCjLRzr+g4goKjTW2V
pugHj1Mwt3PdsZLp8cAiuR/lTbYnZK39NGYFx0DK70WoXr0tc1XMCJnajSO3AlN1
wJHGe5yiPUZcSfUIDfElhtweBH7wyI4pPOMFxdZJ3wtLUl8ikb3KrxDHytzLeYGZ
hzwRapoPca4ogMQ1lluKDpgMKOWQpSfuQKrfs1VL9F+QMCHRqYizXI+zzrAAnsFd
Toc7YqSHoJEK6mEzXu9GNDbDvvs7pZTEiz4701J6v6z9TQMgMwNioPf4+b8Pdl4N
0ZKi0G0Zj7QQdYU7l+duWp2gUUcDW51KpDCxCRAr0p6RcLnB7nSpex8FQXnicv5J
WNhywNNUdGk5+kT+1JS9sREo9usbByz/DDwiHfwKe/wuoj1tIPbu/K2hE56aox+o
jK794kRdDD776rfcIg8anlNdGot1efvIFS9DjAOGNlJNjMCVtyDvdpWT+JhLIWdY
R3G7apNYNVsFhO9E0HyT7RKN0BpGQmvgHawZgTNloYyxXbZIjZlORUuBluvryxIC
+bxtDgQS1FHHzNoKzME2YfYw4c1IRjUmMr37VFzx0DD/Xfcq1KXSrfzHhoKJQMVb
cXqXNS18gLyxRl6iR7R4iteuCBUh+3tNwcD7+u3mooEhhvdjHXPxUS/t1SmB5zRG
gCyOTGv7gdVNuYASR4bk
=eE2p
-----END PGP SIGNATURE-----

--=-Jh2BxjmrGP0CuANpMEfl--



--===============3575780067708992377==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
--===============3575780067708992377==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3575780067708992377==--
