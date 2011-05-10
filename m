From: Noah Meyerhans <noahm@debian.org>
Subject: Re: Bug#625914: linux-image-2.6.38-2-amd64: bridging is not
	interacting well with multicast in 2.6.38-4
Date: Mon, 9 May 2011 21:38:33 -0700
Message-ID: <20110510043833.GG6397@morgul.net>
References: <20110506201234.6297.70279.reportbug@ip6-localhost> <1304995124.4065.157.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lFRK9w0o3gensELN"
Cc: 625914@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:53751 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775Ab1EJFT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 01:19:29 -0400
Content-Disposition: inline
In-Reply-To: <1304995124.4065.157.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--lFRK9w0o3gensELN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 10, 2011 at 03:38:44AM +0100, Ben Hutchings wrote:
> This is pretty weird.  Debian version 2.6.38-3 has a few bridging
> changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like they
> would cause this.

I have apparently filed the bug against the wrong version of Debian's
kernel.  2.6.38-3 is not affected, and works as expected.  The change
was introduced in -4.  That may have been clear from the report itself,
but the report was filed against -3.  I've fixed that in the BTS.

I've also confirmed that -5 is affected, to no great surprise.

I'll investigate further.

noah


--lFRK9w0o3gensELN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFNyMFJYrVLjBFATsMRArhNAJ0bccdvjeUyjmEdwHo7Er+J+mL7qQCbBVb5
3zmB8Esv3xPtfmyLlEV5H6E=
=NP+w
-----END PGP SIGNATURE-----

--lFRK9w0o3gensELN--
