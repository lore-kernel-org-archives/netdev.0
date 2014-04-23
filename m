From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 12:27:35 +0100
Message-ID: <20140423112735.GT12304@sirena.org.uk>
References: <20140414153849.7138699b@endymion.delvare>
 <20140422203209.GH12304@sirena.org.uk>
 <535768E1.8050609@monstr.eu>
 <20140423094010.17d2d763@endymion.delvare>
 <5357897B.6020105@monstr.eu>
 <20140423124838.37aa0759@endymion.delvare>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="exMZW0WqLKvKkpZo"
Cc: monstr@monstr.eu, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:42729 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbaDWL1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 07:27:53 -0400
Content-Disposition: inline
In-Reply-To: <20140423124838.37aa0759@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--exMZW0WqLKvKkpZo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 23, 2014 at 12:48:38PM +0200, Jean Delvare wrote:
> On Wed, 23 Apr 2014 11:35:55 +0200, Michal Simek wrote:
> > On 04/23/2014 09:40 AM, Jean Delvare wrote:

> > > Thanks for the information. I will send a patch adding MICROBLAZE to
> > > the dependencies. Out of curiosity, is there any way I could have found
> > > out by myself?

> > Microblaze doesn't need to be only one. I am not sure if there is
> > any AXI bridge for openrisc.

> You lost me here again :-(

AXI is a bus commonly used inside ICs, it's one of a series of buses of
varying complexity commonly used to integrate IPs into chips.  Michal is
wondering if there is anything available to interface an AXI bus to an
OpenRISC processor.

> > IMHO you should just add COMPILE_TEST and do not try to extend that
> > list of dependencies.

> COMPILE_TEST is already present, I can't add it twice ;-) But
> COMPILE_TEST isn't supposed to be used when the architecture /
> platform / system is actually expected to possibly need the driver in
> question. If the list of possible hardware dependencies isn't well
> known, or is too complex to express, or too difficult to maintain, then
> we have to either make it broader, or even drop it.

Like I said in my original reply for things like this that are clearly
generic IPs not tied to a particular chip vendor I think we ought to at
least create a symbol they can depend on which can be selected by the
architectures that are commonly deployed with FPGAs (or just in custom
silicon like ARM).  That will cover most of the uses I expect.

For some of these IPs there will also be additional places where they
could appear (eg, if something gets put on a PCI card) but they should
be much less common.

--exMZW0WqLKvKkpZo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTV6OkAAoJELSic+t+oim9/VkQAI49ucEkMFvuYO+6dyfH83KF
4Y7F2+uk6ZGeGSiLD5woBvYZg0fmZhoECzUn1ycC8IlVeZq1rqnXlEeFCkZ7hoWe
WdAx2MGv+omIsQFQHXAROwXIoaZfBOxRa6gkgJ/X5bXuefjrjeopeDmxiz5n6rOK
sPlNUPhKwls65TnrkCHcD3jIHqXVTFiJyg/hVAbF06iPPVSEUNJAHAW2puWN18zJ
7gs+Rjc4QkORWiKuiU9rAUw5gtiQ4Hgb+WsIfumlMmCsMUgj5mV9wce/d3vk7cYX
3gcpmB5Gkfz8st3VmOCP0HSzVqN1lS0ujDndoukohPJbGUzbq6h6hmPl9m/CTcE9
u9gUSDdt8u6LZm1EAuCRzROsOMpc1qx3caCrlaBInKIkYeCJhM0uIEsjrsF+dBHu
O+ZqngTx2GpIJHPNpPJNk+A/Ow5UOrfYBKQ+kL63HxPhjRx8+V19bJbEFfHlJaIe
rF+QFk3woaTLQolE0b5DmLqkZzhSmn5ud7pQpn6Ko81rpF5WG3RhVUFrE9KgF3en
UlxykgWJm/MshEVHmZzKZpqwVMLSCIHNWlP4lro/n1j6300YS+vGjAraHJNrm2vG
Hazj943nUx8o0Irj07h6/HfVi21MjQsrmfGS7Lnil4+AlZkCT1S6JLN2kjbNfFV+
K6DAv+gHD9fO8aA5MGgO
=AfPO
-----END PGP SIGNATURE-----

--exMZW0WqLKvKkpZo--
