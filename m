From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 3/6] d80211: add a perm_addr hardware property
Date: Fri, 3 Nov 2006 16:49:27 -0500
Message-ID: <200611031649.32739.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net> <20061102223854.692274000@sipsolutions.net>> <20061102230015.186648000@sipsolutions.net>>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1364916.xAZYnupU7a";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:1357 "EHLO annwn13.rutgers.edu")
	by vger.kernel.org with ESMTP id S932160AbWKCVtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 16:49:52 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20061102230015.186648000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1364916.xAZYnupU7a
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 17:38, Johannes Berg wrote:
> After removing knowledge of the master net_dev from drivers,
> they'll still need a way to tell us which MAC address they have.
> This is that way, the perm_addr is initially used for all devices.
>
Shouldn't you add something to ieee80211_set_mac_address so the driver/d802=
11=20
can find out what MAC address the user actually wants?

Might be easier to just point perm_addr to dev_addr, but that would make it=
=20
obvious that perm_addr is a bit messy. A wrapper for drivers that returns a=
=20
pointer to dev_addr might be a better idea.

Also, do we need to update interfaces associated with the master interface=
=20
when the master MAC address changes?

=2DMichael Wu

--nextPart1364916.xAZYnupU7a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFS7lsT3Oqt9AH4aERAllzAKDGoHCBK6egm7rCL2m84p9iheqmxwCfa46e
FplUrz1RCUyT545lbrhJ2uE=
=VrBP
-----END PGP SIGNATURE-----

--nextPart1364916.xAZYnupU7a--
