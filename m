From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/13] net: Add and use ether_addr_equal
Date: Tue,  8 May 2012 21:56:44 -0700
Message-ID: <cover.1336538937.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-wireless@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Add a boolean function to test 2 ethernet addresses for equality
Convert compare_ether_addr uses to ether_addr_equal

Joe Perches (13):
  etherdevice.h: Add ether_addr_equal
  802: Convert compare_ether_addr to ether_addr_equal
  8021q: Convert compare_ether_addr to ether_addr_equal
  bridge: netfilter: Convert compare_ether_addr to ether_addr_equal
  bridge: Convert compare_ether_addr to ether_addr_equal
  atm: Convert compare_ether_addr to ether_addr_equal
  bluetooth: Convert compare_ether_addr to ether_addr_equal
  mac80211: Convert compare_ether_addr to ether_addr_equal
  mac80211: Convert compare_ether_addr to ether_addr_equal by hand
  netfilter: Convert compare_ether_addr to ether_addr_equal
  wireless: Convert compare_ether_addr to ether_addr_equal
  wireless: Convert compare_ether_addr to ether_addr_equal by hand
  dsa: Convert compare_ether_addr to ether_addr_equal

 include/linux/etherdevice.h               |   12 +++++++++
 net/802/stp.c                             |    2 +-
 net/8021q/vlan.c                          |   10 +++---
 net/8021q/vlan_core.c                     |    3 +-
 net/8021q/vlan_dev.c                      |   10 +++---
 net/atm/lec.c                             |    6 ++--
 net/atm/mpc.c                             |    3 +-
 net/bluetooth/bnep/core.c                 |    6 ++--
 net/bridge/br_device.c                    |    2 +-
 net/bridge/br_fdb.c                       |   14 +++++-----
 net/bridge/br_input.c                     |    2 +-
 net/bridge/br_stp_bpdu.c                  |    2 +-
 net/bridge/br_stp_if.c                    |   11 +++----
 net/bridge/netfilter/ebt_stp.c            |    4 +-
 net/dsa/slave.c                           |   10 +++---
 net/mac80211/cfg.c                        |    2 +-
 net/mac80211/ibss.c                       |   12 ++++----
 net/mac80211/ieee80211_i.h                |    2 +-
 net/mac80211/iface.c                      |    2 +-
 net/mac80211/mesh.c                       |    4 +-
 net/mac80211/mesh_hwmp.c                  |   14 +++++-----
 net/mac80211/mesh_pathtbl.c               |   12 ++++----
 net/mac80211/mlme.c                       |   29 +++++++++------------
 net/mac80211/rx.c                         |   39 +++++++++++++---------------
 net/mac80211/scan.c                       |    2 +-
 net/mac80211/sta_info.c                   |    8 +++---
 net/mac80211/sta_info.h                   |    2 +-
 net/mac80211/status.c                     |    2 +-
 net/mac80211/tx.c                         |   11 +++----
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    4 +-
 net/netfilter/xt_mac.c                    |    2 +-
 net/wireless/ibss.c                       |    2 +-
 net/wireless/mlme.c                       |   31 +++++++++++------------
 net/wireless/scan.c                       |    2 +-
 net/wireless/util.c                       |   11 +++----
 net/wireless/wext-sme.c                   |    2 +-
 net/wireless/wext-spy.c                   |    2 +-
 37 files changed, 147 insertions(+), 147 deletions(-)

-- 
1.7.8.111.gad25c.dirty
