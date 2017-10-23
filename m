From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 0/3] pull request for net-next: batman-adv 2017-10-23
Date: Mon, 23 Oct 2017 17:37:01 +0200
Message-ID: <20171023153704.32120-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:54104 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdJWPhI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:37:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

here is another small documentation/cleanup pull request of batman-adv to go
into net-next.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 4bc4e64c2cfdafa6b8ecdcc5edf10cc1a147587f:

  Merge tag 'batadv-next-for-davem-20171006' of git://git.open-mesh.org/linux-merge (2017-10-06 10:12:52 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20171023

for you to fetch changes up to 40b16b9be5773a314948656c96adf7bf7cfdbd0b:

  batman-adv: use inline kernel-doc for uapi constants (2017-10-23 14:22:25 +0200)

----------------------------------------------------------------
This documentation/cleanup patchset includes the following patches:

 - Fix parameter kerneldoc which caused kerneldoc warnings, by Sven Eckelmann

 - Remove spurious warnings in B.A.T.M.A.N. V neighbor comparison,
   by Sven Eckelmann

 - Use inline kernel-doc style for UAPI constants, by Sven Eckelmann

----------------------------------------------------------------
Sven Eckelmann (3):
      batman-adv: Add missing kerneldoc for extack
      batman-adv: Avoid spurious warnings from bat_v neigh_cmp implementation
      batman-adv: use inline kernel-doc for uapi constants

 include/uapi/linux/batman_adv.h | 369 +++++++++++++++++++++++++++++++---------
 net/batman-adv/bat_v.c          |   9 +-
 net/batman-adv/soft-interface.c |   1 +
 3 files changed, 295 insertions(+), 84 deletions(-)
