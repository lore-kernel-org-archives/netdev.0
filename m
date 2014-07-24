From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-07-24
Date: Thu, 24 Jul 2014 14:18:14 -0400
Message-ID: <20140724181813.GE3256@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49228 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758807AbaGXSaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 14:30:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.16 stream...

For the mac80211 fixes, Johannes says:

"I have two fixes: one for tracing that fixes a long-standing NULL
pointer dereference, and one for a mac80211 issue that causes iwlmvm to
send invalid frames during authentication/association."

and,

"One more fix - for a bug in the newly introduced code that obtains rate
control information for stations."

For the iwlwifi fixes, Emmanuel says:

"It includes a merge damage fix. This region has been changed in -next
and -fixes quite a few times and apparently, I failed to handle it
properly, so here the fix.  Along with that I have a fix from Eliad
to properly handle overlapping BSS in AP mode."

On top of that, Felix provides and ath9k fix for Tx stalls that happen
after an aggregation session failure.

Please let me know if there are problems!  There are some changes
here that will cause merge conflicts in -next.  Once you merge this
I can pull it into wireless-next and resolve those issues.

John

---

The following changes since commit 2c4db12ec469b9fcdad9f6bfd6fa20e65a563ac5:

  rt2800usb: Don't perform DMA from stack (2014-07-07 15:04:34 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-07-23

for you to fetch changes up to c01fac1c77a00227f706a1654317023e3f4ac7f0:

  ath9k: fix aggregation session lockup (2014-07-23 13:03:11 -0400)

----------------------------------------------------------------
Eliad Peller (2):
      cfg80211: fix mic_failure tracing
      iwlwifi: mvm: pass beacons from foreign APs

Emmanuel Grumbach (1):
      iwlwifi: mvm: fix merge damage

Felix Fietkau (2):
      mac80211: fix crash on getting sta info with uninitialized rate contr=
ol
      ath9k: fix aggregation session lockup

Johannes Berg (1):
      Revert "mac80211: move "bufferable MMPDU" check to fix AP mode scan"

John W. Linville (3):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-fix=
es
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211

 drivers/net/wireless/ath/ath9k/xmit.c       |  9 +++++++++
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c | 15 +++++++++++++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c |  7 -------
 net/mac80211/cfg.c                          |  5 ++++-
 net/mac80211/tx.c                           | 20 ++++++++++----------
 net/wireless/trace.h                        |  3 ++-
 6 files changed, 38 insertions(+), 21 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJT0U3lAAoJEJctW/TcYTgGBv4P/RqLOVkNku36T79sHmXqmr76
ckP931P75OfMmDu0Ft4k7hdf4b9+zJmcAjEk4pxkcdNeo2X5Nbd20H0izmCd6xI8
aehkf9iOCybx/TC2A2K5speWF8o4b8KZkyuKqZAsvhNjrPpPH2NqZYq7AZlPcj1B
Wkiso5WW67tOSreqNIKnVwCnYOODFIn+FzKhtWLdydUz4RSmDoQ48s43lrv/X305
prpd9LGakFmpK5W085/oUKB4a/K/h1qZA5p/YRIzfAnO5Upq+t2OW5Eblln3etlB
6LKkEfpnGs7yX5gaU4PP94qe+afN1h7gsL8SgeClsDI0hiMPKgtOPhW9HBsptfHF
hWqU6V+W8XIQLAaZ3NYrbY1xz+uCGqiHmd2bylsuiY6qFiyWOkbRklnnF/5xOkTf
fhJgURnQqT+YEiCtRq1+UoI5d5mZY+5qEpWm1/cv1sHDZoaYDFQT+RqwzEVTnhxv
rU5AGZtG9/uMCJYqKUapbnYLvHVK5PLugUXEKb/tAo/j/zzawJaA19jJR49maP0k
I2kwNFGNqpDO8QhKa/EsjGLDR1CcHnRl23hTUrSUg1UhduG1IWovLv4+miFNKRHT
rx3acBVTU5eF3HuM2fH9ULkRquDkKhYMqnTr6BcJonhSUZZDHE+fNNr7R44nYSYO
8/f0ZVzpve/17eeYvlTn
=JSQv
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--
