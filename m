From: Michael Wu <flamingice@sourmilk.net>
Subject: d80211-drivers updated (zd1211rw-d80211 synced with zd1211rw)
Date: Mon, 4 Dec 2006 02:50:39 -0500
Message-ID: <200612040250.43955.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart27101685.FISB4SX8rk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:59032 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1759005AbWLDHv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 02:51:29 -0500
To: Daniel Drake <dsd@gentoo.org>, Ulrich Kunitz <kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart27101685.FISB4SX8rk
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,
	I've just "ported" 8 patches that were in the wireless-2.6 version of=20
zd1211rw that weren't in the wireless-dev version. All of them, except for=
=20
the cleanups patch, applied with just an offset, and all of the broken hunk=
s=20
in the cleanups patch were just thrown away since the code they were=20
modifying doesn't exist anymore.

      zd1211rw-d80211: Fix of a locking bug
      zd1211rw-d80211: Revert "zd1211rw: Removed unneeded packed attributes"
      zd1211rw-d80211: Add 3 more device IDs
      zd1211rw-d80211: Add ID for ZyXEL G-220
      zd1211rw-d80211: Add ID for Planex GW-US54Mini
      zd1211rw-d80211: Add ID for Belkin F5D7050 v4000
      zd1211rw-d80211: cleanups
      zd1211rw-d80211: Optimized handling of zero length entries in length=
=20
info

git://git.kernel.org/pub/scm/linux/kernel/git/mwu/d80211-drivers.git

These patches are in the week-48 branch. (I think it should actually be=20
week-49, but I realized after I committed..) I'll post a pull request at th=
e=20
end of every week when there are patches and branch. Patches sent here can =
be=20
expected to be merged in a day. Other (d80211) wireless drivers are welcome=
=20
to send patches this way if they do not have their own git tree for Linvill=
e=20
to pull.

Currently, patches are going into the week-48 branch, but I will switch to=
=20
putting patches in the master branch and branching off master before every=
=20
pull request for next week.

=2DMichael Wu

--nextPart27101685.FISB4SX8rk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFc9NTT3Oqt9AH4aERAt3gAKCommktFVBX59LIsrL3vv5fh9s2SQCgkD7C
kgfhpON4EPbS7itVLMZSZlI=
=S0RP
-----END PGP SIGNATURE-----

--nextPart27101685.FISB4SX8rk--
