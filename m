From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Wed, 10 Dec 2014 15:02:34 -0600
Message-ID: <20141210210234.GN4602@saruman>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
 <20141204165609.GJ18045@saruman>
 <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman>
 <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="v541l457l4DThMFo"
Cc: Felipe Balbi <balbi@ti.com>, netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47391 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933253AbaLJVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 16:02:39 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--v541l457l4DThMFo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Dec 10, 2014 at 09:58:23PM +0100, Yegor Yefremov wrote:

[snip]

> >> git revert failed as the driver has more changes meanwhile or I'm
> >> missing some params. I've tried to force the driver to use legacy
> >> routines, but then I don't get pass U-Boot's "Starting kernel ..." See
> >> attached patch.
> >>
> >> Compiler used:
> >>
> >> Linux version 3.18.0-rc7 (...) (gcc version 4.8.3 20140320
> >> (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #309 SMP Fri Dec 5
> >> 10:59:38 CET 2014
> >>
> >> Btw, what am335x based hardware do you have? I can run tests on both
> >> BBB and am335x-evmsk.
> >
> > coming back to this. I have BBB only. Can you provide some extra
> > information on how I can trigger this problem here ?
>=20
> I have basically two am335x based boards, where I can trigger this

too bad, I have a single am335x board available here and that's my BBB.

Do both boards stall or only the server or only the client ?

If only one of them fail, then I try connecting my BBB to my AM437x SK
and see if that'll die too.

> problem via nuttcp (I think iperf would do the job too). The first
> system stalls almost immediately, the second one was working for about
> 7 minutes. I have tried the same kernel on am335x-evmsk - and this
> system didn't stall. I could provide dts files for both systems.
>=20
> I've tried to reduce my dts as much as I could to match  am335x-evmsk
> dts, I have even removed entries for the PMIC, but still the system
> stalls. Btw PMIC's INT line is connected to a GPIO pin on processor.
>=20
> I've used omap2plus_defconfig for all 3 devices. Any other info I can
> supply?

just the extra bit of info above.

--=20
balbi

--v541l457l4DThMFo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUiLTqAAoJEIaOsuA1yqREZPYP+wTiGR7Tx1ujlt9HeNHXf9QE
kqHeXniHRN7VAgHcLIyULi7AwmI3wPe9l45JABpPSeIgL/4ssu3N4yk1VNKFgirT
YTm2u5Tn7wDD/g8h6spUJYlAUi6j9YelyEjuM2234nG3+/tZK8pjh8wGTBAvSKME
3IO2gFWO17Z4LYXSygoDQn/otrJ6h4fGZCecEZNC/BaOj3duV4wNPFoNRPOzwXpu
6bT5MECb/BnciJv2XYVelCKf7lCf5TmNCwc2q6C96kAJgT/v9imxFnordMTotUiq
TsY/Y5gmbmWz7QeSg8a/tQL5JUuy/aCPBUXvMYiH1mtpjbyfUyMgSpZIDwtgLi1c
+WbI8/d5wbDnKzkDoZkM+8kbKCokSLB4HSQKsV3uwsXcJHK/27PuCUjIPbNtDyy3
CqrMrBS/R0GcjDTlAzMBRCrf++C+dlScJfYcFkac4J14Lokjag+oX/cIi9tNee/+
d2gHHfcnoHemFYIsb2iI5prHD3yGLd2b61ByZ/HYNEoUtlDuIIrqyXSk3n9AMWVX
XTLMZAT5HlI6rstXiGIoJCFeWO4wCi2r71XCCPbSgO8ZpkBhtVDw0QJuip9XyKt8
lrG0QEh2UsgyuFCMcZwSYWly7ky3VzmzsZdokrf8lst9pn/dBDpqKQ9zkgvdiYI4
BY0V9fHgzaDhG9yWQha6
=RA1F
-----END PGP SIGNATURE-----

--v541l457l4DThMFo--
