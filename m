From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [patch 2/3] d80211: remove poorly documented ieee80211_hw extra_hdr_room flag
Date: Tue, 10 Oct 2006 10:30:36 -0400
Message-ID: <200610101030.41213.flamingice@sourmilk.net>
References: <20061009170159.804032000@devicescape.com> <200610101200.12454.mb@bu3sch.de> <20061010134533.GB4518@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3017823.ex0XT4a9Gq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:59684 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1750826AbWJJObl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 10:31:41 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061010134533.GB4518@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3017823.ex0XT4a9Gq
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 10 October 2006 09:45, David Kimdon wrote:
> On Tue, Oct 10, 2006 at 12:00:12PM +0200, Michael Buesch wrote:
> > On Monday 09 October 2006 19:03, David Kimdon wrote:
> > > This flag is unused by all in tree drivers.  Furthermore, the way that
> > > it is documented is not consistent with the way it is actually used by
> > > ieee80211.c.  The original attempt appears to be something to do with
> > > adding extra header room for low-level drivers which need to pad the
> > > IEEE 802.11 header (example: Atheros).
> >
> > What about not removing it, but extending it.
>
> Sure, I would be happy with that.  For Atheros it will be '2' to
> ensure that we can properly align the packet in the tx path without
> needing to realloc.
>
adm8211 needs this too to avoid realloc and possibly failing and dropping t=
he=20
packet. (except adm8211 needs closer to about 30 bytes of extra room to fit=
=20
its hardware tx header)

Thanks,
=2DMichael Wu

--nextPart3017823.ex0XT4a9Gq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD4DBQBFK66RT3Oqt9AH4aERAiJgAJdCZMGevsgQZIRe8Kj8TZ2vjkO6AKDWeKT7
KY94Qm4JcpFvhRjdWJpdHA==
=8CRk
-----END PGP SIGNATURE-----

--nextPart3017823.ex0XT4a9Gq--
