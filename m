From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 00:35:22 +0200
Message-ID: <1216247722.3422.38.camel@johannes.berg>
References: <20080716220058.GA31425@amd64.fatal.se>
	 <20080716150320.63f20215@extreme>
	 <1216247237.31646.12.camel@amd64.fatal.se>
	 <20080716152631.04125f56@extreme>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qbch3D0FGHbNWo+i6mkB"
Cc: Andreas Henriksson <andreas@fatal.se>,
	stephen.hemminger@vyatta.com, 489340@bugs.debian.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:36278 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758686AbYGPWf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 18:35:29 -0400
In-Reply-To: <20080716152631.04125f56@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qbch3D0FGHbNWo+i6mkB
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > (By the way, most uses of rtnl_* seems to be if (rtnl_* < 0) exit(1); i=
n
> > iproute2 currently. The error messages are in libnetlink.)

> The problem is the driver is responding with an error packet but the
> errno is 0. This looks like a kernel bug, not an library bug.

I don't think so, the recvmsg() call worked fine, but the message
indicates that the netlink consumer had an error. Or am I missing
something?

johannes

--=-qbch3D0FGHbNWo+i6mkB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfnemAAoJEKVg1VMiehFYr2oP+wbLyj39N3XV4rBWX0H4neaB
NfnikyKGOTpHLMtp7PJoLu10Cx2ZRW1wGhTIzY4mooAoC7w076R/Gtntq63F1+yw
QZDOyScwtM8CS7YfnHNs26AEPUaXA7pAPzWuCVylPikx789dPN1BQuLhCdA90iiq
zvKf2vk+Zh2lWdkjwDIX8AvZPeOSB2mV+2v0qmqV+GMiiCPwIxKmJC5qYPhHdf/2
lYv6hOESrahky7ENmcbVSEWmcdx4DnOMUiZmqkXD6YNoz3tBgfBoKCKYLvKSBypx
sx487bLxX5VdVH/rgaJ63ORC11Ls5IQPYNucjIZnU3zqBes4doiFqANXhrJgY/GK
2aUF4Ls92DVdskh5248AUUtge8UX5yfH9IxlZvUEJDL8lrtZ7/6oFCijVJmbo4hY
qwLQbfwbd4+uZdhZUuwxTXnToWh17W6jib9woD5EpPBtorNS6jbPbZ5OhLXpOEG5
NQb8EUM5U0tGoXulFYHXbIvBAhOdlinBPAm6G2meSGNM3pW+Q+E7FjVOAgVwFwjv
K68v56wBQ9YY1WlaFfB0qYYcRZMJY0zso85chpPQ/fPmDlu7+l4eQqT4TpZ/PpYN
4HlA7cT3kfWXH900/eWIpV8H25y90ZFxivBwjvJVDrvhn6QZ7LCyXlbyeoaGtw8i
2px9mIEBls278CybqzMh
=fOrn
-----END PGP SIGNATURE-----

--=-qbch3D0FGHbNWo+i6mkB--

