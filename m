From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Regulator support for smsc911x
Date: Tue, 7 Feb 2012 19:39:14 +0000
Message-ID: <20120207193914.GA31557@opensource.wolfsonmicro.com>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
 <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
 <20120203074408.GD1990@pengutronix.de>
 <20120203111133.GD3151@opensource.wolfsonmicro.com>
 <CAOMZO5B2_yq=m8Mer=iV-HsXvF-MZJ-BV2=LTg1CZN+O=yepSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	robert.marklund@stericsson.com, netdev@vger.kernel.org,
	Sascha Hauer <kernel@pengutronix.de>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:53043 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755937Ab2BGTjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:39:17 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5B2_yq=m8Mer=iV-HsXvF-MZJ-BV2=LTg1CZN+O=yepSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 07, 2012 at 05:25:48PM -0200, Fabio Estevam wrote:
> On Fri, Feb 3, 2012 at 9:11 AM, Mark Brown

> > There's also options c) set up the regulators for the board and d) don't
> > enable the regulator API if the board doesn't use regulators.

> Option c would require that we change every single board.

Well, yes.

> The patch below does option d.

> What do you think?

Absolutely not.  Putting conditional code like this in drivers is nuts,
you would have to do the same thing in every single driver which is not
a useful use of anyone's time.  This is *clearly* a generic thing and
should therefore be handled in generic code for the same reason we don't
have driver specific platform data for actual usage of the API.

Really, anyone who wants this sort of thing should just enable dummy
regulators - it's exactly what you're implementing.  I'm pretty sure
your board does actually have power supplies for the chip, you've just
not told software about them.

--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPMX3cAAoJEBus8iNuMP3dKUIQAI0DiF3SCyZYiqBn0L6WeD+o
va22mYzdroeNlFBVWbKnEouxLcAi2LMGXnHBz3qfKlSpQ1VcZQba1EMnJ6vIIFWq
dAMhoMEryA1h1NyK72woQT3WiUzKsIbOwMZlEwcBYKXBJuXshoKNlw6VIe47IQQB
XuDd8mqCzDAaOL1tUZ4z+5ymlhMpLmzj1ZXTwmM5koJL1stwx594oa3fpjxPIq0s
pE1hzRP+WZLQokCaPPSWBJhHkIg3DtON09xcw/bgo5zibVjKJ5I++PcPXw8dyAYt
Dr7fXpskPCHc/4mXyMurPRC2adeb8hxjAfc/RJkaaOKjHdlt/NZ5MoWqTdeCBogP
DqpF7HF8kVmabN3snTwh4tw7pgxRhInw7zBe/vn/2e0ZN8nNUPAZuAZiG9uSzTG1
sIyEaYYgUm1DXlAivSIKQUok7MIaWJLw4ygoBRDgWgIUN14j8irkFAugmRpCk7gM
pffq1ekj7GDFV6EI0JR0lG4wE9sIV5+e+4Qlv4hrDxkvESia3jPVSAuraLUs+VRF
l30uF89AxhGZkbd1IxdRqu1SW5PMPMP5u5aXM7nzFfcjNl/sutQJzTe/+dgSs/7Q
KA4XQurYT7IbUpgvQgJN1aX7uV8Kwtf/7a9YRFE1V5bVW9GkodSJpcsHC0tvXYBx
dubwFu1+T8A3i3Y7qozB
=r6Vp
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
