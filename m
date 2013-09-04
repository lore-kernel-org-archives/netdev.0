From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/2] prandom_u32_range, prandom_u32_max helpers
Date: Wed,  4 Sep 2013 14:37:25 +0200
Message-ID: <1378298247-29364-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v1->v2:
  - migrated api to random.h, ccing lkml
  - dropped second patch for now

Daniel Borkmann (2):
  random: add prandom_u32_range and prandom_u32_max helpers
  net: migrate direct users to prandom_u32_max

 drivers/net/team/team_mode_random.c |  8 +-------
 include/linux/random.h              | 31 ++++++++++++++++++++++++++++++-
 include/net/red.h                   |  2 +-
 net/802/garp.c                      |  3 ++-
 net/802/mrp.c                       |  3 ++-
 net/packet/af_packet.c              |  2 +-
 net/sched/sch_choke.c               |  8 +-------
 7 files changed, 38 insertions(+), 19 deletions(-)

-- 
1.7.11.7
