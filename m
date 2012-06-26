From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 16:56:46 +0100
Message-ID: <1340726206.5330.11.camel@deadeye.wl.decadent.org.uk>
References: <1340696951-2686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	  <20120626.005029.909254566674577767.davem@davemloft.net>
	  <1340697238.2255.20.camel@jtkirshe-mobl>
	 <1340719768.5330.2.camel@deadeye.wl.decadent.org.uk>
	 <4FE9D9C2.5010209@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-USui2tYXGDC8eBtMGaQ6"
Cc: jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53548 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757594Ab2FZP46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 11:56:58 -0400
In-Reply-To: <4FE9D9C2.5010209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-USui2tYXGDC8eBtMGaQ6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-06-26 at 08:48 -0700, Alexander Duyck wrote:
> On 06/26/2012 07:09 AM, Ben Hutchings wrote:
> > On Tue, 2012-06-26 at 00:53 -0700, Jeff Kirsher wrote:
> >> On Tue, 2012-06-26 at 00:50 -0700, David Miller wrote:
> >>> Sorry, quotes don't work either, what you did is still a SMTP syntax =
error,
> >>> here's what is in the bounce I get back:
> >>>
> >>> 	<stable@vger.kernel.org> "[3.4]",
> >>> 	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>> Illegal-Object:	Syntax error in Cc: address found on vger.kernel.org:
> >>> 	Cc:	<stable@vger.kernel.org>"[3.4]"
> >>> 						^-missing end of address
> >> Grrr...
> >>
> >> I will re-send without the "[3.4]", Greg will just have to deal with i=
t.
> > It's certainly not necessary to put anything like that in the real Cc
> > header. Many people put something like
> > 'Cc: <stable@vger.kernel.org> # 3.4' in the body; I don't know if that
> > is more like likely to result in the version being stripped when
> > generating mail recipients.
> >
> > Ben.
> >
> Couldn't 3.4 have been put in place of the recipient's name?  So you do
> something like this:
> Cc: 3.4 <stable@vger.kernel.org>

Aside from the fact that recipient names with dots must be quoted in the
real header, it's relatively uncommon to use this format and the import
script I use for 3.2.y wouldn't notice it.  (So I'd have to go back and
look at the original commit header to work out that it wasn't relevant.)
I don't know whether Greg's script extracts the recipient name.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-USui2tYXGDC8eBtMGaQ6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT+nbv+e/yOyVhhEJAQqVeg//Wba8qZREtyarm4Ih+l/lmY9gqLRLXllo
jKol9iSwFHZMkJv6h9+8Gi3jDSbnRfZ4DxAR5gS4P5RkWmzluvX26fcWNRCCSg+v
ORMrhb/LVwSsFq1A555Aqfo2Mq9ZHd/781ydu4+BOcrBBEZeQIYSHEMmy9N3267j
XemNe37tvRyyc62W1gkdNwISIPI9nbJUrzWX0nFvc4RvO4An8gfcPKY2R9Zr1SPE
eIdEWn5yvWHPZtDyivZ0Rf2ltv4gla0YuFGQBflxt3FgWJqmO8+TqHe8oSVTECUm
GCu5xTgbb9D9L6NwcezkV2UqAnMLzzX4IUSTDEqvi9hGNEdgV79//hkSvXcDCaT4
s3ruz5YNoNs78bWJ69wicNBNJXgzzrTqLfohjWlHW5g7owrCeh4zWdWpWdsU3GLJ
nishBQljXXjyK31Cu9cnYryMy5bxJytnMoqgzYDIweKCk65xUozX7th2tPJ1yZ+D
v/YZWGTUzOxYNIAHwSCL7CIeSxduMNDnYmUrF8wH1cqNEvcA7k/rW01mXvoCJu8Q
HeEa2gqf/Fn+EI+kX898y+dMkVqXlo69IJdy4HIpwKXGN03qggHXeRlobSJnDo7S
Fa6KEawq84/horGtSj5E7j8BqhYCFCm2VM0OeKgY+BVJSz05A35N4aYrjdnPNnyP
PfrimNLAYoc=
=zODY
-----END PGP SIGNATURE-----

--=-USui2tYXGDC8eBtMGaQ6--
