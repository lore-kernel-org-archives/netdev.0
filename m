From: Noah Meyerhans <noahm@debian.org>
Subject: Re: [Bridge] Bug#625914: linux-image-2.6.38-2-amd64: bridging is
	not interacting well with multicast in 2.6.38-4
Date: Tue, 10 May 2011 16:35:40 -0700
Message-ID: <20110510233540.GJ6397@morgul.net>
References: <20110506201234.6297.70279.reportbug@ip6-localhost> <1304995124.4065.157.camel@localhost> <20110510043833.GG6397@morgul.net> <1305031369.4065.259.camel@localhost> <20110510180540.GI6397@morgul.net> <20110510151100.52a9f8fa@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eG/Mb3lYspOUTzsV"
Cc: Ben Hutchings <ben@decadent.org.uk>, 625914@bugs.debian.org,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:38069 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147Ab1EJXft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 19:35:49 -0400
Content-Disposition: inline
In-Reply-To: <20110510151100.52a9f8fa@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eG/Mb3lYspOUTzsV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 10, 2011 at 03:11:00PM -0700, Stephen Hemminger wrote:
> There were two more follow on commits in stable related to this.
> I recommend merging 2.6.38.6 which includes these.

The problem still exists in the current 2.6.38.6.  Backing out 5f1c356a
still solves the problem there.

I have not yet tried anything outside the stable-2.6.38.y tree, but it
seems like these same changes are present there, and it's unlikely that
other releases will work any better.

noah


--eG/Mb3lYspOUTzsV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFNycvMYrVLjBFATsMRAtE+AJ4oljwI4R9IjPry0LPRQtwKFzKAAQCfSKHG
yltJbT+2nnGncOdzlG0carA=
=9r7t
-----END PGP SIGNATURE-----

--eG/Mb3lYspOUTzsV--
