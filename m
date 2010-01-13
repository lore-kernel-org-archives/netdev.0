From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Wed, 13 Jan 2010 02:04:31 +0000
Message-ID: <1263348271.3852.74.camel@localhost>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
	 <alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
	 <alpine.WNT.2.00.1001061525050.4056@jbrandeb-desk1.amr.corp.intel.com>
	 <alpine.WNT.2.00.1001121720300.3168@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-SSs+j9bBTH2pnT3j27gM"
Cc: Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36458 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab0AMCEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 21:04:43 -0500
In-Reply-To: <alpine.WNT.2.00.1001121720300.3168@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SSs+j9bBTH2pnT3j27gM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-01-12 at 17:56 -0800, Brandeburg, Jesse wrote:
> On Wed, 6 Jan 2010, Brandeburg, Jesse wrote:
> > a counter patch, without atomic ops, since we are protected by napi whe=
n=20
> > modifying this variable.
> >=20
> > Originally From: Neil Horman <nhorman@tuxdriver.com>
> > Modified by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >=20
> > <original message>
> > Hey all-
> > 	A security discussion was recently given:
> > http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> > And a patch that I submitted awhile back was brought up.  Apparently so=
me of
> > their testing revealed that they were able to force a buffer fragment i=
n e1000
> > in which the trailing fragment was greater than 4 bytes.  As a result t=
he
> > fragment check I introduced failed to detect the fragement and a partia=
l
> > invalid frame was passed up into the network stack.  I've written this =
patch
> > to correct it.  I'm in the process of testing it now, but it makes good
> > logical sense to me.  Effectively it maintains a per-adapter state vari=
able
> > which detects a non-EOP frame, and discards it and subsequent non-EOP f=
rames
> > leading up to _and_ _including_ the next positive-EOP frame (as it is b=
y
> > definition the last fragment).  This should prevent any and all partial=
 frames
> > from entering the network stack from e1000.
> >=20
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>=20
> I would like to withdraw this patch, at least for 2.6.32+ e1000 and e1000=
e=20
> are both not susceptible to this attack.  We have verified the below with=
=20
> testing, including code modifications to guarantee the correct paths were=
=20
> taken when receiving overlong frames.
[...]
> I believe RedHat has not backported this patch, and kernels <=3D 2.6.31=20
> still need the fix, so both need some version of this workaround, but=20
> 2.6.32 does not.
[...]

There's also the 2.6.27 stable series, and several long-term supported
distributions.  I'm particularly interested in getting a patch for
Debian 5.0's kernel based on 2.6.26.  Please advise what would be a
suitable change for the older kernel versions.

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-SSs+j9bBTH2pnT3j27gM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS00qK+e/yOyVhhEJAQI5jQ//STeKgrHx8Hi+Eht7sV1xI4wCTtcd6f2Z
5IdgOJ/GN0OSKoX47okMndOSVK7ihB1y2XX3VuVMAaOjEF4XCAy7U3AilSGEAc0L
IlSdRaHeuGiRNcMRsy8cXGaVFj0BrYT8i22MqZcWyL9JEjiVikkslNYmQO9fA8Yy
19jHtGrlxW6Wnx7gvyn1Py8kMgtP90rgGnyfdyiOIkoxehoe0wOooGaHFMl+oz12
RjbU88LfYx2r0peXWOlaoDql/VWe8tZP+CnXNUn0oS9mg7Tq+vqznLP8AYATmU5g
hm8UhI/xweMQ+e98iVsAMiRDGnvKqoQhWwI69CXdWYaMLJgjQakLcuDKAzxi2Aa9
mRI9z7dwQ8IEgOF2zzw+SwJAx1Df7zguKlZmGdFam8Jcwpz03/jowIAd6Y4Vs9Bq
mEMCcgXtzz5tIu0ZeQ1XVta75R/gR79j5Xb/vX+8DO03ZGUpL2yYjoZcsfuS1SA9
/TXG2kNadY7DYQvEgCEX5mgcUKaluJZDdwk6gFIElCyL65hfZYvZGNeAN1axajL7
bNmXvSs9xqsEmJEHyISiEzZAhnd9XX76StbfIvg04mWz9MmZaOxE0S4sQvULaC5M
EWI+rJ9hDJliVYuXlzANQtlmJQioRo8zMpXkL7HFJKZrnwi7yoh7m2VKXE7r3deA
E4Do94Z5zCQ=
=l8vl
-----END PGP SIGNATURE-----

--=-SSs+j9bBTH2pnT3j27gM--
