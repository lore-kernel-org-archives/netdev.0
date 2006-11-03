From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 5/6] d80211: add a ethtool_ops hardware property
Date: Fri, 3 Nov 2006 17:43:08 -0500
Message-ID: <200611031743.15770.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net> <20061102223854.692274000@sipsolutions.net>> <20061102230016.080591000@sipsolutions.net>>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8133595.4Mdo3h3DHh";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:32644 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1753497AbWKCWn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 17:43:26 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20061102230016.080591000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8133595.4Mdo3h3DHh
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 17:39, Johannes Berg wrote:
> After removing knowledge of the master net_dev from drivers,
> some will still want to have ethtool ops assigned (rt2x00 uses
> it). This is that way.
But bcm43xx sets ethtool ops through bcm43xx_netdev_setup. Why not have rt2=
x00=20
do the same? Then we won't have to go through all the trouble of adding=20
things to ieee80211_hw and ieee80211_register_hw to set things in net_devic=
e.=20
This would work out pretty well for SET_NETDEV_DEV too.

=2DMichael Wu

--nextPart8133595.4Mdo3h3DHh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFS8YDT3Oqt9AH4aERAubtAJ4oJLiI8psLiE6rdzMV8Z538OEavwCg2J70
BVH0WVI/7sQ5coS6uZAfPHE=
=RDb7
-----END PGP SIGNATURE-----

--nextPart8133595.4Mdo3h3DHh--
