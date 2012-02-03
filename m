From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Regulator support for smsc911x
Date: Fri, 3 Feb 2012 11:11:34 +0000
Message-ID: <20120203111133.GD3151@opensource.wolfsonmicro.com>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
 <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
 <20120203074408.GD1990@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Xm/fll+QQv+hsKip"
Cc: Fabio Estevam <festevam@gmail.com>, robert.marklund@stericsson.com,
	netdev@vger.kernel.org, Sascha Hauer <kernel@pengutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:50118 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755690Ab2BCLLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 06:11:36 -0500
Content-Disposition: inline
In-Reply-To: <20120203074408.GD1990@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Xm/fll+QQv+hsKip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Feb 03, 2012 at 08:44:08AM +0100, Sascha Hauer wrote:
> On Fri, Feb 03, 2012 at 01:17:23AM -0200, Fabio Estevam wrote:

> > Please advise if I should fix it in Kconfig or defconfig, so that I
> > can submit a patch.

> If you enable it every device will get a regulator when it requests one.
> If for some reason for example the initialization order of your devices
> changes and a device gets probed before the corresponding (real)
> regulator is registered, then this device will continue with the dummy
> regulator and probably won't work.

Hrm, yeah - the dummy regulator support will be totally broken by the
stuff Grant is working on for fixing the general issues with probe
ordering.

> We could a) live with this problem and default enable the dummy
> regulator. We could also b) apply (a fixed version of) the following
> patch which simplifies registration of a dummy regulator. Still it's a

There's also options c) set up the regulators for the board and d) don't
enable the regulator API if the board doesn't use regulators.

> bit annoying to have to fix all users once someone adds regulator
> support for a driver.

Yeah, it's a shame.  I really can't see anything else useful we can do
though.

--Xm/fll+QQv+hsKip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPK8DYAAoJEBus8iNuMP3dPlkP/RKrmgvKsRDyp9MORJy09uvY
D5t8YL7c2RNYyA+uzkeLSwsoJoX4sZJC+j96euTksIBA3BBFGEXShQoFhujFiAPo
kEJ5SHU/2ulQMHKcqyJysGF7U60VPfAHElCyS+HgoB8zu5T4X20WP+qPCf/q3XgO
6lgZVmq1R/ezYBkYRv+L5MCYfL5RRPj3yZXgLCub0JfbR02NafgH71gEX+TO3SOw
j1eq0MObs5dTcZS/rVjqSRQs+e0gY2fAJ4wnmhTdqaFO8FjR+/Yga5EjURLENxoP
pMWOGH/v4DZviCyRWxdL1f3IUBGVB2FC6+sEhOZ0MbfFCGpcSrjq2udlfp35kD/i
JoGnW/FR3bNTqel/JacHCnCe0ZwKX8BHqQnzPLBlIo1bTzEhhrjm8BFSA2gwkZmt
/2r1jVJkHkwRu2Frc7jUEDl7wh+3BIyTNZRkmI6BW/rao0fhkSLIjk2emxQmMFUN
4EMRGfFX05fe8OrXe/NOl6dpLUacU9qPOkMNAvGeYkeHadw2wLDC5shFWYcLeBtv
uO6tFEWjeW0Pv+tBWBBSEovaH9nltpfsXP+RK67pH0ixIIPTh+Au2ApfFqZjzKQ1
RTlMHR9w7H53S5gvyGfxFBrEv8r+LaaSEhaDqAUGOiFNR/Ak8vKVINDB5dGXIqyj
Mnh6bECB7sTF2Ch9w95c
=Zn7L
-----END PGP SIGNATURE-----

--Xm/fll+QQv+hsKip--
