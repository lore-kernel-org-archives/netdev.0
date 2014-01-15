From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] reciprocal_divide updates
Date: Thu, 16 Jan 2014 00:23:46 +0100
Message-ID: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set is on top of Eric's BPF fix, that is:

   http://patchwork.ozlabs.org/patch/311163/

Daniel Borkmann (1):
  random32: add prandom_u32_lt_N and convert "misuses" of reciprocal_divide

Hannes Frederic Sowa (1):
  reciprocal_divide: correction/update of the algorithm

 drivers/net/bonding/bond_main.c     | 16 +++++++-------
 drivers/net/bonding/bond_netlink.c  |  4 ----
 drivers/net/bonding/bond_options.c  |  9 +++-----
 drivers/net/bonding/bond_sysfs.c    |  5 -----
 drivers/net/bonding/bonding.h       |  3 +++
 drivers/net/team/team_mode_random.c |  8 +------
 include/linux/flex_array.h          |  3 ++-
 include/linux/random.h              | 19 ++++++++++++++++-
 include/linux/reciprocal_div.h      | 42 ++++++++++++++++++++++---------------
 include/linux/slab_def.h            |  4 +++-
 include/net/codel.h                 |  4 +---
 include/net/red.h                   |  3 ++-
 lib/flex_array.c                    |  3 ++-
 lib/reciprocal_div.c                | 28 +++++++++++++++++++++----
 net/packet/af_packet.c              |  5 ++---
 net/sched/sch_choke.c               |  9 +-------
 net/sched/sch_netem.c               |  4 +++-
 17 files changed, 99 insertions(+), 70 deletions(-)

-- 
1.8.3.1
