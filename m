From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ixgbe: RTNL assertion failed
Date: Mon, 6 May 2013 07:58:28 -0700
Message-ID: <20130506075828.717864ba@nehalam.linuxnetplumber.net>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
	<F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
	<20130504015406.GP2619@decadent.org.uk>
	<F6FB0E698C9B3143BDF729DF222866464C28E2AE@ORSMSX110.amr.corp.intel.com>
	<1367702492.5106.164.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/zSnm3Eg2n0G7+ix7fqqLWxw"; protocol="application/pgp-signature"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:55197 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815Ab3EFO6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 10:58:32 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so2052412pdj.27
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 07:58:31 -0700 (PDT)
In-Reply-To: <1367702492.5106.164.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/zSnm3Eg2n0G7+ix7fqqLWxw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 04 May 2013 22:21:32 +0100
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Sat, 2013-05-04 at 21:05 +0000, Skidmore, Donald C wrote:
> [...]
> > > The version of ixgbe in this Debian kernel has bql support backported=
, but is
> > > otherwise the same as in 3.2.41.  I assume that this bug has been fix=
ed some
> > > time between 3.2 and 3.9, but no-one requested that the fix be includ=
ed in
> > > stable branches.  Please can you identify the fix?
> > >=20
> > > Ben.
> > >=20
> > > --
> > > Ben Hutchings
> > > We get into the habit of living before acquiring the habit of thinkin=
g.
> > >                                                               - Alber=
t Camus
> >=20
> > I believe this is the patch:
> >=20
> > commit 34948a947d1a576c10afee6d14792fd237549577
> > Author: Benjamin Poirier <bpoirier@suse.de>
> > Date:   Fri Apr 6 07:20:21 2012 +0000
> >=20
> >     ixgbe: add missing rtnl_lock in PM resume path
> [...]
>=20
> Looks like it.  And it applies cleanly to 3.2.y.  Stephen, could you
> test this on top of 3.2.y and then nominate it for stable?
>=20
> Ben.
>=20

Patch works.
Tested with 3.2.44 with this patch and there is no problem.

--Sig_/zSnm3Eg2n0G7+ix7fqqLWxw
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRh8UUAAoJEICnf2CVzeR+2awP/1kHJdSbCJle6rldFgwis0IP
pW2pGDPaafRScEJzLm4DKaGuRa7WS2+CS+nMirdhOhc7bie5oVKS/eFDPgnJgZBS
DemQhWUHVjt+FLMYKvM0iGJW2vhjlTPiOHZvB2abCOlC0sWW2lECImJ9ayGtngxM
lG6Ix8h4opYcV73xuWCR8jek1JvC3iNGwpNY7jUz86CKRBnnvRXmsPKKKK81U5qr
woz0c+x+qZbC7Ypc/HN83fmPZe4772Y7N8r+dpEf0eFh3bwZQiPwmSKTn11rLrrL
cQX3MetYlVvNHFx4J1rQUZXSH2+t9k8N7znHTxfYXyR6AVqcGzuUC8/HBGoOrOmb
PbSB7RRYZFx9FttzZaK+/PNNAhYlxkdFVqMGKvfCoN81Z3sQarGmC0dC2d2IhS9k
evXiENkxEbVChn3ipdcUD5aUG6ky5+LlVWc2iArtWD5W50mcQHqtu+4ED214epd3
hR23N6LOlVF0L7adkUg86+8TW4dDS7PrYdvLF5sHMhEX/KW+nPzC+EsmzFW6YT5N
ehIPWyPl++OJeNXTDSOOiGLk6fu1imHC9E2hBOmFLL7vcMt0nR5dbML3uSSO35uw
0HtVAilSN2dW+3QhHMwHqLtFU/vavw1CL54nR3MjCx7Po+BWlVDf1AMmEzxXxcZL
XnIhtdcb36kZTqT7Tid8
=wn0n
-----END PGP SIGNATURE-----

--Sig_/zSnm3Eg2n0G7+ix7fqqLWxw--
