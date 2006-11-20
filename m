From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] d80211: remove useless driver name field
Date: Mon, 20 Nov 2006 13:44:03 -0500
Message-ID: <200611201344.08794.flamingice@sourmilk.net>
References: <1163802439.3392.47.camel@johannes.berg> <1163803835.3392.52.camel@johannes.berg> <20061120183213.GB5983@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1285558.26g16SoGRt";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:48451 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP id S966420AbWKTSpQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 13:45:16 -0500
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20061120183213.GB5983@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1285558.26g16SoGRt
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Monday 20 November 2006 13:32, Jouni Malinen wrote:
> Is this the same name field that was in struct ieee80211_hw? It was used
> and the main reason was to allow rate control algorithms to be
> implemented in a way which allows hardware specific features (e.g.,
> different TX/RX status data) to be used to optimize rate selection. I
> would not remove this field unless there is another way of allowing
> something like this to be done in the rate control modules.
But there's no code in the tree that actually uses it.

Also, for drivers that properly use SET_NETDEV_DEV, it was accessible by:
	ndev->class_dev.dev->driver->name
Or, with these patches applied:
	hw->dev->driver->name

-Michael Wu

--nextPart1285558.26g16SoGRt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFYfd4T3Oqt9AH4aERAsL+AJ9KA8VlSZm4GSsz5XBvWvFgbtRubgCgxf3t
oRv3rGRB0AtPjf3P5ajJED4=
=j+oF
-----END PGP SIGNATURE-----

--nextPart1285558.26g16SoGRt--
