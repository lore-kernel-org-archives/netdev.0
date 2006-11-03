From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Thu, 2 Nov 2006 21:28:24 -0500
Message-ID: <200611022128.29060.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net> <20061102230013.960383000@sipsolutions.net>> <1162513367.3381.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1963974.kp4PgUn74l";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:43728 "EHLO
	annwn13.rutgers.edu") by vger.kernel.org with ESMTP
	id S1752953AbWKCC2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 21:28:40 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162513367.3381.11.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1963974.kp4PgUn74l
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 19:22, Johannes Berg wrote:
> Ok, that one was wrong. But what is it doing in the public API? We need
> to remove it from the public API and leave struct net_device *dev as the
> parameter. adm8211 actually uses it and increases the tx_fifo_error
> counter, but that's a bit strange.
>
That's because TX might fail for reasons other than not getting an ACK. I=20
can't say I've actually seen this happen, so it might just be something lef=
t=20
over from tulip that doesn't need to be there now. (or perhaps it only=20
happens when there's something really bad going on) However, what's so bad=
=20
about letting drivers update some statistics if it is possible? If you remo=
ve=20
ieee80211_dev_stats, please provide some other way for drivers to access=20
struct net_device_stats.

=2DMichael Wu

--nextPart1963974.kp4PgUn74l
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFSqlMT3Oqt9AH4aERAm31AJ9LBJ3Nb4MSldJjHrY/65BAsn0jJACgwdIe
WFy9FoG/4XBdrG300k/ycRE=
=4L3U
-----END PGP SIGNATURE-----

--nextPart1963974.kp4PgUn74l--
