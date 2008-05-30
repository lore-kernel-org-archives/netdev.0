From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 30 May 2008 03:04:30 -0700 (PDT)
Message-ID: <20080530.030430.20211983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756167AbYE3KEs@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Keeping the fixes rolling:

1) Two DCCP bug fixes from Gerrit and the DCCP crew.

2) Merge in wireless fixes from John Linville and co.

3) LLC double ref bug fix from Arnaldo.

4) Netfilter conntrack expection fix from Alexey Dobriyan.

Please pull, thanks a lot!

The following changes since commit 289c79a4bd350e8a25065102563ad1a183d1b402:
  Patrick McHardy (1):
        vlan: Use bitmask of feature flags instead of seperate feature bits

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Fixes the status message for iwconfig

Alexey Dobriyan (1):
      netfilter: nf_conntrack_expect: fix error path unwind in nf_conntrack_expect_init()

Andrea Merello (3):
      rtl8180: fix wrong parameter in sa2400_rf_set_channel
      rtl8180: fix wrong parameter in max2820_rf_set_channel
      rtl8180: fix wrong parameter in grf5101_rf_set_channel

Arjan van de Ven (1):
      bluetooth: fix locking bug in the rfcomm socket cleanup handling

Arnaldo Carvalho de Melo (1):
      llc: Fix double accounting of received packets

David S. Miller (1):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6

Gerrit Renker (1):
      dccp ccid-3: Fix "t_ipi explosion" bug

Guy Cohen (2):
      iwlwifi: fix exit from stay_in_table state
      iwlwifi: fix rate scale TLC column selection bug

Ivo van Doorn (4):
      rt2x00: Fix memleak in tx() path
      rt2x00: Don't count retries as failure
      rt2x00: Reset antenna RSSI after switch
      rt2x00: Use atomic interface iteration in irq context

John W. Linville (1):
      rtl8180: avoid NULL dereference in max2820_rf_set_channel

Jussi Kivilinna (1):
      rndis_wlan: add missing range check for power_output modparam

Michael Buesch (2):
      b43: Upload both beacon templates on initial load
      b43: Fix controller restart crash

Nicolas Kaiser (1):
      net/mac80211: always true conditionals

Scott Ashcroft (1):
      rndis_wlan: Make connections to TKIP PSK networks work

Senthil Balasubramanian (2):
      mac80211: Fix for NULL pointer dereference in sta_info_get()
      mac80211: fix alignment issue with compare_ether_addr()

Tomas Winkler (2):
      mac80211: fix ieee80211_rx_bss_put/get imbalance
      mac80211: reorder channel and freq reporting in wext scan report

Wei Yongjun (1):
      dccp: Fix to handle short sequence numbers packet correctly

Yi Zhu (1):
      mac80211: fix a typo in ieee80211_handle_filtered_frame comment

 drivers/net/wireless/b43/b43.h             |    1 +
 drivers/net/wireless/b43/main.c            |   70 +++++++++++++++++++++------
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c |    3 +-
 drivers/net/wireless/rndis_wlan.c          |   65 +++++++++++++++++++++++++-
 drivers/net/wireless/rt2x00/rt2x00.h       |    5 ++
 drivers/net/wireless/rt2x00/rt2x00config.c |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c    |    8 ++--
 drivers/net/wireless/rt2x00/rt2x00mac.c    |    1 +
 drivers/net/wireless/rtl8180_grf5101.c     |    2 +-
 drivers/net/wireless/rtl8180_max2820.c     |    5 +-
 drivers/net/wireless/rtl8180_sa2400.c      |    2 +-
 net/bluetooth/rfcomm/core.c                |    2 +-
 net/dccp/ccids/ccid3.c                     |   13 ++----
 net/dccp/ipv4.c                            |    4 +-
 net/llc/llc_sap.c                          |   10 ++--
 net/mac80211/cfg.c                         |    4 +-
 net/mac80211/main.c                        |    2 +-
 net/mac80211/mlme.c                        |   29 ++++++-----
 net/mac80211/rx.c                          |    4 +-
 net/mac80211/util.c                        |    4 +-
 net/mac80211/wext.c                        |   11 +++-
 net/netfilter/nf_conntrack_expect.c        |    4 +-
 22 files changed, 180 insertions(+), 70 deletions(-)
