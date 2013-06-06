From: Mark Brown <broonie@kernel.org>
Subject: Re: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Thu, 6 Jun 2013 09:50:49 +0100
Message-ID: <20130606085049.GL31367@sirena.org.uk>
References: <1370452099-24026-1-git-send-email-mugunthanvnm@ti.com>
 <1370452099-24026-2-git-send-email-mugunthanvnm@ti.com>
 <20130605192345.GH31367@sirena.org.uk>
 <51B0254B.4090304@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SAsyYo4aAOH7Cuht"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	devicetree-discuss@lists.ozlabs.org, linux-omap@vger.kernel.org,
	benoit.cousson@linaro.org, paul@pwsan.com,
	Hebbar Gururaja <gururaja.hebbar@ti.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:37077 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab3FFIu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 04:50:56 -0400
Content-Disposition: inline
In-Reply-To: <51B0254B.4090304@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SAsyYo4aAOH7Cuht
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 06, 2013 at 11:29:39AM +0530, Mugunthan V N wrote:
> On 6/6/2013 12:53 AM, Mark Brown wrote:

> >Linus Walleij posted some patches which factor the state setting code
> >out into generic functions earlier on today - it probably makes sense to
> >pick those up rather than open coding

> But this can go in as Linus Walleij's patch is not accepted yet.
> Once that is
> accepted and present in net git repo I will submit a separate patch to use
> those APIs from pin ctrl core.

Linus' change has pretty much gone in already but in any case what would
be sensible here would be to write this in turns of Linus' changes and
then send the patch to him to add to his series so it can go in via the
same route.  One of the major reasons for the patch was that lots of
people were querying the amount of noise caused by this sort of change.

--SAsyYo4aAOH7Cuht
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJRsE1mAAoJELSic+t+oim9z4AP/i+QCxt9Ek78M2R9ja3KZLh3
mGk/tEu2xDZXX/UryLrThjZgqfXbna1EUiFJeq0egujTVAWLUybO/ve0vLdudpby
tsIGtI5yUNh23ew1Eqj3zMuvGeWKDjCyhxGYg8tldd9WHFa6yJuJxYQ93l4q3sCw
f6ykchFhtHnkYbOsK8XAwkUd/EdqWJbtyTaPKIzr4OBj5EGLjnM395fhpo2jJu+V
rTZvVWiBNwYVfh2U3Tk1vyJlC50DwKoTCXvb2nO+KaW5FSUois0BpchQgYtsMvGq
hiaP78ZESmwy7uSyDvV3xTMS9QdJ4ouLqr2Pqt18qj6LZbAitu6XF8Kt3NWs8L/0
+dIboAKPM80RrKIOoQyOmFfoG0HKd1iHCLoZbCAt7c9togyYnESgAq3Ccsg3+3ru
rl5B3QROlveklDIL04HC+B2jeR8qNyHzpekwYI+PTybY4v9ghFDiyryL+fpw/ccE
k86TBh9l1etHIza4SfW4G21B1Yt7lvIDtK+EYfFHwJNGKNCltQZOy/5JxFHHT2DE
/73vy+LZuc2knowq5mePG4qv89D4VDraWlgdLdMKsPHTsq1Uu/v1CIpo5oz6TxiD
Fbb0BjzRdn2Rwkic5Uqz8x1lyeLMdwPlAbwpP3U8YyI9a9D+y8H77URpUocK2Hu9
+ntkhXTtY58btWOxjcbX
=NVRU
-----END PGP SIGNATURE-----

--SAsyYo4aAOH7Cuht--
