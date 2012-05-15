From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] net: mac80211: Neaten debugging
Date: Tue, 15 May 2012 14:20:29 -0700
Message-ID: <cover.1337116578.git.joe@perches.com>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
Cc: linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Always use pr_debug variants instead of printk(KERN_DEBUG...)

Joe Perches (3):
  net: mac80211: Convert printk(KERN_DEBUG to pr_debug
  net: mac80211: Add and use ht_vdbg debugging macro
  net: mac80211: Add and use ibss_vdbg debugging macro

 include/net/mac80211.h        |   24 ++++++++
 net/mac80211/agg-rx.c         |   30 +++------
 net/mac80211/agg-tx.c         |  109 +++++++++-------------------------
 net/mac80211/cfg.c            |    4 +-
 net/mac80211/debugfs_netdev.c |    2 +-
 net/mac80211/ibss.c           |  111 ++++++++++++----------------------
 net/mac80211/iface.c          |    4 +-
 net/mac80211/mesh.c           |    3 +-
 net/mac80211/mesh_hwmp.c      |    2 +-
 net/mac80211/mesh_pathtbl.c   |    2 +-
 net/mac80211/mesh_plink.c     |    2 +-
 net/mac80211/mesh_sync.c      |    2 +-
 net/mac80211/mlme.c           |  131 ++++++++++++++++++-----------------------
 net/mac80211/rx.c             |   22 +++----
 net/mac80211/sta_info.c       |   23 +++-----
 net/mac80211/status.c         |    2 +-
 net/mac80211/tkip.c           |   21 +++----
 net/mac80211/tx.c             |   14 ++---
 18 files changed, 204 insertions(+), 304 deletions(-)

-- 
1.7.8.111.gad25c.dirty
