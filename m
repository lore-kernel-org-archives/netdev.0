From: Sven Eckelmann <sven@narfation.org>
Subject: pull request: batman-adv 2011-01-30
Date: Sun, 30 Jan 2011 13:11:40 +0100
Message-ID: <1296389504-11208-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45217 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab1A3MLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 07:11:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to propose following patches for net-2.6.git/2.6.38. These=
 are
important fixes for kernel oopses/memory leaks. I already send this exa=
ct same
request in 201101301036.57928.sven@narfation.org were you requested a n=
ew patch
series posting.

I cannot reduce the number of fixes any more because it makes no sense =
to fix
one Oops and leave the other one open. I've already removed the fixes f=
or the
protocol implementation errors from the first patchset.

The following changes since commit aa0adb1a85e159cf57f0e11282bc6c9e3606=
a5f3:

  batman-adv: Use "__attribute__" shortcut macros (2011-01-16 03:25:19 =
+0100)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/merge-oopsonl=
y

Linus L=C3=BCssing (1):
      batman-adv: Fix kernel panic when fetching vis data on a vis serv=
er

Sven Eckelmann (3):
      batman-adv: Remove vis info on hashing errors
      batman-adv: Remove vis info element in free_info
      batman-adv: Make vis info stack traversal threadsafe

 net/batman-adv/vis.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

 Thanks,
 	Sven
