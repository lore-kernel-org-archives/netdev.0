From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH v2 1/1] e1000e: Undo e1000e_pm_freeze
 if __e1000_shutdown fails
Date: Tue, 27 Jun 2017 13:51:05 -0700
Message-ID: <1498596665.3244.2.camel@intel.com>
References: <20170531.110833.1362264472730468352.davem@davemloft.net>
 <20170531155043.3596-1-jani.nikula@intel.com>
 <20170531155043.3596-2-jani.nikula@intel.com>
 <20170602.141426.713378366601051907.davem@davemloft.net>
 <1496781986.86439.3.camel@intel.com>
 <309B89C4C689E141A5FF6A0C5FB2118B8C61D137@ORSMSX101.amr.corp.intel.com>
 <20170620084958.7fxdn57p3o6eexbj@phenom.ffwll.local>
 <CAPM=9tzdpEDoMNYj7Z_ZM3Z0JsCpjfNW1Z+y-1p5z3HssJ5aaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1650381367=="
Cc: "daniel.vetter@ffwll.ch" <daniel.vetter@ffwll.ch>
To: Dave Airlie <airlied@gmail.com>, "Brown, Aaron F"
 <aaron.f.brown@intel.com>,  David Miller <davem@davemloft.net>, "Nikula,
 Jani" <jani.nikula@intel.com>, "Ursulin, Tvrtko"
 <tvrtko.ursulin@intel.com>, "intel-gfx@lists.freedesktop.org"
 <intel-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "jani.nikula@linux.intel.com"
 <jani.nikula@linux.intel.com>, "chris@chris-wilson.co.uk"
 <chris@chris-wilson.co.uk>, "Ertman, David M" <david.m.ertman@intel.com>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAPM=9tzdpEDoMNYj7Z_ZM3Z0JsCpjfNW1Z+y-1p5z3HssJ5aaw@mail.gmail.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org


--===============1650381367==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-G+hROn9sIc5vtyDBRhDs"


--=-G+hROn9sIc5vtyDBRhDs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-06-28 at 05:28 +1000, Dave Airlie wrote:
> On 20 June 2017 at 18:49, Daniel Vetter <daniel@ffwll.ch> wrote:
> > On Wed, Jun 07, 2017 at 01:07:33AM +0000, Brown, Aaron F wrote:
> > > > From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org]
> > > > On Behalf
> > > > Of Jeff Kirsher
> > > > Sent: Tuesday, June 6, 2017 1:46 PM
> > > > To: David Miller <davem@davemloft.net>; Nikula, Jani
> > > > <jani.nikula@intel.com>
> > > > Cc: Ursulin, Tvrtko <tvrtko.ursulin@intel.com>; daniel.vetter@ffwll
> > > > .ch; intel-
> > > > gfx@lists.freedesktop.org; linux-kernel@vger.kernel.org;
> > > > jani.nikula@linux.intel.com; chris@chris-wilson.co.uk; Ertman,
> > > > David M
> > > > <david.m.ertman@intel.com>; intel-wired-lan@lists.osuosl.org; dri-
> > > > devel@lists.freedesktop.org; netdev@vger.kernel.org; airlied@gmail.
> > > > com
> > > > Subject: Re: [Intel-wired-lan] [PATCH v2 1/1] e1000e: Undo
> > > > e1000e_pm_freeze if __e1000_shutdown fails
> > > >=20
> > > > On Fri, 2017-06-02 at 14:14 -0400, David Miller wrote:
> > > > > From: Jani Nikula <jani.nikula@intel.com>
> > > > > Date: Wed, 31 May 2017 18:50:43 +0300
> > > > >=20
> > > > > > From: Chris Wilson <chris@chris-wilson.co.uk>
> > > > > >=20
> > > > > > An error during suspend (e100e_pm_suspend),
> > > > >=20
> > > > > =C2=A0...
> > > > > > lead to complete failure:
> > > > >=20
> > > > > =C2=A0...
> > > > > > The unwind failures stems from commit 2800209994f8 ("e1000e:
> > > > > > Refactor PM
> > > > > > flows"), but it may be a later patch that introduced the non-
> > > > > > recoverable
> > > > > > behaviour.
> > > > > >=20
> > > > > > Fixes: 2800209994f8 ("e1000e: Refactor PM flows")
> > > > > > Bugzilla: https://bugs.freedesktop.org/show_bug.cgi?id=3D99847
> > > > > > Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> > > > > > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > > > Cc: Dave Ertman <davidx.m.ertman@intel.com>
> > > > > > Cc: Bruce Allan <bruce.w.allan@intel.com>
> > > > > > Cc: intel-wired-lan@lists.osuosl.org
> > > > > > Cc: netdev@vger.kernel.org
> > > > > > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > > > > > [Jani: bikeshed repainted]
> > > > > > Signed-off-by: Jani Nikula <jani.nikula@intel.com>
> > > > >=20
> > > > > Jeff, please make sure this gets submitted to me soon.
> > > >=20
> > > > Expect it later tonight, just finishing up testing.
> > >=20
> > > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> >=20
> > Hm, I seem to be blind, but I can't find it anywhere in -rc6. Does
> > someone
> > have the sha1 from Linus' git for this patch?
>=20
> Guys this is a pretty serious regression, just left blowing in the
> wind, is anyone responsible for e1000e?

This was submitted and accepted into David Miller's net-next tree.  I can
see if Dave can pull it into his net tree.  DOes stable need to pick this
up as well?
--=-G+hROn9sIc5vtyDBRhDs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZUsU5AAoJEOVv75VaS+3OcOMP/0xZfZTkPvUB7xtmxzvnnkFI
Y1puWXLEjyswoXY/lnb7l5GKi6WCrrl9/WVwGTSXhThMhSRikPfhtucxPUt6zpxF
sWWxQ0NQFohnHjoNthd3NIYyimC71ubGaTwhWkkmiWroSsZdcdqcbur+tiQud6YL
7Z/MQO2s4dsrgrOXMhg/dxKhFi1HfdQ3f/IeCz+pH+MOHXJeQzO51eXV0GJaudCs
6ZAx+VeKxblq1x3Qopk6pJpUHgCtCHoVyiiChN07yDoAau1L8bm88oz6NCKmjjFP
CkaCMS6PfDIxvVghFP2RZ6uF0E2nDKkiZZ2Ct+qoHl0oKyf+3uLX3v71Ccp5HCBz
8J0elVvSSpyintoC/rwfbtDCvEvVq59Y2qL9ch7UPftJkiyVqL1n4KGjEDaSENcU
IeSnfoEBxgI+nhHgnT4ERcevOC7Iq8Idx+2NSSUGz19bFAxPHDLtssv9xqBUSuUt
kWYLgALNKFjejy+DNj16kKhnAe9I2p9KjVmiktZgaludhievVoaqMky3md2GLZJ4
C0hisLLbicr2W2d+51Xfv4IwYx3dAX8jokbWdf/M3uAzVJqr4j6j8f/9orJgez9v
o6h0hEcbmLPdaL0kmETZC3ZWPkZ109uVXnSz9yyiTmT1mmqVDiubj2q1m+xIziLd
BzVB9WkfTgn21pO6axU9
=p5/O
-----END PGP SIGNATURE-----

--=-G+hROn9sIc5vtyDBRhDs--


--===============1650381367==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZHJpLWRldmVs
IG1haWxpbmcgbGlzdApkcmktZGV2ZWxAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlz
dHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vZHJpLWRldmVsCg==

--===============1650381367==--
