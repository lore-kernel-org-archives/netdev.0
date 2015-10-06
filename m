From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg is
 marked volatile
Date: Tue, 6 Oct 2015 11:13:05 +0100
Message-ID: <20151006101305.GG12635@sirena.org.uk>
References: <1444051772-20270-1-git-send-email-jon@ringle.org>
 <20151005145722.GT12635@sirena.org.uk>
 <20151005.232956.105884641412802470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="+BArgJ+dbJ88VxBZ"
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:46763 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbJFKNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 06:13:53 -0400
Content-Disposition: inline
In-Reply-To: <20151005.232956.105884641412802470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+BArgJ+dbJ88VxBZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 05, 2015 at 11:29:56PM -0700, David Miller wrote:
> From: Mark Brown <broonie@kernel.org>

> > Dave, to be clear please do *not* apply this patch at least for the time
> > being - I've not reviewed it or the one from Thursday that you applied
> > this morning.

> It's applied, it's pushed out to my tree, and therefore this will need to
> be fixed up with a relative patch of some sort.

This appears to be an incremental change, not the initial commit which
you already applied.  I'm asking you to stop applying changes to regmap
which have not been reviewed.

> What you don't seem to understand is that my GIT tree is never rebased
> or mangled because many people depend upon it.  So once a patch is
> applied, that commit lives on forever.

I'm not *so* concerned if the patch lives in history, I'm concerned with
having something I can sensibly review and ideally getting the code into
my tree.

--+BArgJ+dbJ88VxBZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWE56sAAoJECTWi3JdVIfQNssH/1vCR/CISeiC8/ot1cp3SFjO
HvhpqyHW2Sg/0cRmKIVQOlUzF+XcdXWtBrEhZ5LiBs7RF0bIpvVgFiX37rv1xLZw
U3b2nVh0GWyQuV/UxTCHadCeWQdkg4p+quIpxpucdhaNR6wSkPMHwxil3diE82tq
w44F228+oWCnbcSgigAcnzDW9ruDsnREJqGscRK4ZADL9+JBcCEXd/0fSy+hnTfR
wHrxLGQcE8Ma6RES06nWsrTzPYE4fL+QIJ3GEl9MI918nQuUu+ew352ZoEQBc/n/
kvymf89AD59LImSqGh2KK+sFTHG0KZuLOWb2+OvnQ3Myf2126Vdak2ajea59bEo=
=9Xnz
-----END PGP SIGNATURE-----

--+BArgJ+dbJ88VxBZ--
