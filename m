From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net]: 20160107
Date: Thu,  7 Jan 2016 15:26:26 +0800
Message-ID: <1452151587-25547-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:28830 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbcAGH2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 02:28:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

I know it is extremely late in the release cycle, but please accept this
single (and small) change intended for net.

This bug-fix provided by Sven Eckelmann prevents a wrong memory access
in setups with multiple interfaces enslaved in batman-adv (very common
nowadays).

When such bad access is performed the code ends up filling with random
data an internal data structure used to compute the links metric, thus
leading to undefined behaviours.


This bug is there since ever, therefore it would be really nice if could
get it queued for inclusion in stable.


Please pull or let me know of any problem!
Thanks a lot,
	Antonio


The following changes since commit 51cb67c0b0fcb91581b15bd2e85f29af4d4b2df6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-01-06 16:15:03 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 13bbdd370f67aef3351ad7bbc2fb624e3c23f905:

  batman-adv: Fix invalid read while copying bat_iv.bcast_own (2016-01-07 14:24:05 +0800)

----------------------------------------------------------------
Included change:
- Fix invalid read while copying bat_iv.bcast_own by Sven Eckelmann

----------------------------------------------------------------
Sven Eckelmann (1):
      batman-adv: Fix invalid read while copying bat_iv.bcast_own

 net/batman-adv/bat_iv_ogm.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
