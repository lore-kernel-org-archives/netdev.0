From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e100: Don't enable WoL by default on
	Toshiba devices
Date: Wed, 12 Nov 2014 19:38:47 -0800
Message-ID: <1415849927.2454.14.camel@jtkirshe-mobl>
References: <1415832445-9524-1-git-send-email-linux@rainbow-software.org>
	<20141112.181813.1072534293888457853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1846044302945590981=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux@rainbow-software.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20141112.181813.1072534293888457853.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============1846044302945590981==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nAQO+zSoHwI27HSlOxQS"


--=-nAQO+zSoHwI27HSlOxQS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-12 at 18:18 -0500, David Miller wrote:
> From: Ondrej Zary <linux@rainbow-software.org>
> Date: Wed, 12 Nov 2014 23:47:25 +0100
>=20
> > Enabling WoL on some Toshiba laptops (such as Portege R100) causes batt=
ery
> > drain after shutdown (WoL is active even on battery). These laptops hav=
e the
> > WoL bit set in EEPROM ID, causing e100 driver to enable WoL by default.
> >=20
> > Check subsystem vendor ID and if it's Toshiba, don't enable WoL by defa=
ult
> > from EEPROM settings.
> >=20
> > Fixes https://bugs.launchpad.net/ubuntu/+source/linux/+bug/110784
> >=20
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
>=20
> Jeff, are you gonna pick this up?

Yes, sorry I did not catch it earlier.

--=-nAQO+zSoHwI27HSlOxQS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZCfHAAoJEOVv75VaS+3Oe2EQAIZvu1sjhsf9SEk9VrakOsW5
6Sm98oEo1fu35bWFHrlESiVyG8Jsil0Ev5UR/UbZunHhAJ1vx43+wjXPBHY249rl
kogGDoie/8AvSKsE5SMk2IqAMKPBLue8h1Md+sFRFZCGaZvS/zWvGBtcWCYNn3Xf
pNYcel3md643HLHl/o+pNzvKtkAFhTWvYIT60jnIyE30/6EvSsWJjPlBFBPKZQuq
uSawYFfQQ5zoK5cEvI/UcMiLu4CPR4K2DOJpOJYXZ1ZRO8wv3n32H3i3/c3c+ouz
7mKfaFOCU27g5EMZ94lHF2EODDm10UA6Fn+OrtIZpKZvNbyH6aYPvGxKDNgFmrrz
UXKQnt+NGqnhtNyeH7fNtcDuPiOFr/7AtJGU/71PEN8K1IJRl6uHJ6UyxlXYJWDt
DTDTOPzRMmvHKnFlXBqhuJo1PmrO1K2R5hYuNwEwVdcxbsdlNn6KEMKp2OaWR+bl
+3PwfseMLFIzbdVDvHe9VF6wQyhaCZgOuNYpx+6ItXzPs3k0obQFbNrbAnXjtt5p
/WcTmWqnDk3XRaihQiesMrWr2HbnDAb+/5Zhv1s7H5zfstYcPQsYSAObEosQfaQV
n4HInkM16Cm6CCON7Hx6Cnz6LdGxqFlwV+9g/KJKcBMVUHDSi4KkHomIjiiJ2zKU
HPjy00La1+62FJYpE7JQ
=1mvp
-----END PGP SIGNATURE-----

--=-nAQO+zSoHwI27HSlOxQS--



--===============1846044302945590981==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Comprehensive Server Monitoring with Site24x7.
Monitor 10 servers for $9/Month.
Get alerted through email, SMS, voice calls or mobile push notifications.
Take corrective actions from your mobile device.
http://pubads.g.doubleclick.net/gampad/clk?id=154624111&iu=/4140/ostg.clktrk
--===============1846044302945590981==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============1846044302945590981==--
