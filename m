From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-11-24
Date: Tue, 24 Nov 2009 15:53:10 -0500
Message-ID: <20091124205310.GB2782@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58219 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932746AbZKXVAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 16:00:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another week, another century (more-or-less) of patches intended
for 2.6.33...  Mostly the usual kind of stuff: lots of iwlwifi, some
ath9k, some wl12xx, a bunch of mac80211 bits from Johannes, and misc
other bits.  Included is the reintroduction of my cfg80211 conversion
for ipw2200 and a follow-up for ipw2100 from Matthew Garrett.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/
=09
---

The following changes since commit dfef948ed2ba69cf041840b5e860d6b4e16f=
a0b1:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wire=
less-next-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Ben M Cahill (4):
      iwl3945: Reset saved POWER_TABLE_CMD in "up"
      iwlwifi: Add comments about CSR registers
      iwlwifi: Add iwl_write8()
      iwlagn: Use iwl_write8() for CSR_INT_COALESCING register

Benoit PAPILLAULT (1):
      ath9k: This patch fix RX unpadding for any received frame.

Christian Lamparter (1):
      ar9170: do not discard valuable DUPOFDM frames

Daniel C Halperin (2):
      iwlwifi: fix bugs in beacon configuration
      iwlwifi: make iwlwifi send beacons

David-John Willis (1):
      wl1251: add NVS in EEPROM support

=46elix Fietkau (3):
      mac80211: reduce the amount of unnecessary traffic on cooked moni=
tor interfaces
      mac80211: add the total ampdu length to tx info
      ath9k: get rid of tx_info_priv

Janne Ylalehto (2):
      wl1251: Add IRQ looping support
      wl1251: Filter out unwanted events

Jaswinder Singh Rajput (1):
      mac80211: Fix missing kernel-doc notation

Jay Sternberg (1):
      iwlwifi: Tell the ucode immediately when association state change=
s

Johannes Berg (24):
      iwlwifi: report PS filtered status
      iwlwifi: add sleep_tx_count ucode station API
      iwlwifi: handle unicast PS buffering
      mac80211: let sta_info_get_by_idx get sta by sdata
      mac80211: convert aggregation to operate on vifs/stas
      mac80211: push michael MIC report after DA check
      mac80211: cleanup reorder buffer handling
      mac80211: trim RX data
      mac80211: improve rate handling
      mac80211: remove dev_hold/put calls
      mac80211: use fixed broadcast address
      mac80211: make software rate control optional
      cfg80211: re-join IBSS when privacy changes
      mac80211: remove encrypt parameter from ieee80211_tx_skb
      mac80211: move TX status handling
      cfg80211: convert bools into flags
      cfg80211: introduce capability for 4addr mode
      cfg80211: disallow bridging managed/adhoc interfaces
      mac80211: request TX status where needed
      mac80211: avoid spurious deauth frames/messages
      mac80211: add per-station HT capability file
      mac80211: remove dead struct member
      mac80211: fix rcu locking
      iwlwifi: separate IO tracing

John W. Linville (3):
      wl3501_cs: remove pedantic build warning
      libipw: initiate cfg80211 API conversion (v2)
      ath9k: set ps_default as false

Jouni Malinen (1):
      cfg80211: Allow reassociation in associated state

Jussi Kivilinna (2):
      rndis_wlan: fix buffer overflow in rndis_query_oid
      rndis_wlan: disable stall workaround

Juuso Oikarinen (5):
      wl1251: Add connection monitoring configuration
      wl1251: Enable beacon filtering with the stack
      wl1251: Configure beacon filtering on if PSM used
      wl1251: Implement delayed entry into ELP mode
      wl1251: Fix regression in IRQ loop handling

Kalle Valo (3):
      wl1251: allocate space for firmware with vmalloc()
      wl1251: mask aid bits 14 and 15 in ps-poll template
      wl1251: remove depcreated qual usage

Larry Finger (1):
      ssb: Unconditionally log results of core scans

Luk=C3=A1=C5=A1 Turek (1):
      ath5k: Fix I/Q calibration

Marcel Holtmann (2):
      rfkill: Add missing description for RFKILL_TYPE_GPS
      rfkill: Add constant for RFKILL_TYPE_FM radio devices

Matthew Garrett (2):
      ipw2100: Register the wiphy device
      ipw2200: Set core hw rfkill status when hardware changes state

Michael Buesch (4):
      b43: Enforce DMA descriptor memory constraints
      b43: Rewrite DMA Tx status handling sanity checks
      ssb: Fix SPROM writing
      ssb: Fix range check in sprom write

Reinette Chatre (2):
      iwlagn: power up device before initializing EEPROM
      iwl3945: removed unused struct and definitions

Rui Paulo (3):
      mac80211: use a structure to hold the mesh config information ele=
ment
      mac80211: update cfg80211 scan result code for the updated mesh c=
onf IE
      mac80211: fix endianess on mesh_path_error_tx() calls

Sujith (5):
      ath9k: Cleanup bss_info_changed callback
      ath9k: Remove a few unused variables
      ath9k: Remove a few unused functions
      ath9k: Fix bug in initializing chain masks
      mac80211: Fix panic in aggregation handling

Thomas Klute (1):
      ar9170: Add support for D-Link DWA 160 A2

Vidhya Govindan (4):
      wl1251: Add acx command to set tbtt and dtim period
      wl1251: Set the correct dtim period to the firmware
      wl1251: Increase the beacon loss timeout value and handle regain =
event
      wl1251: Send null data packet with "TODS" bit set

Wey-Yi Guy (21):
      iwlwifi: validate enhanced tx power entry
      iwlwifi: disable coex until implementation ready for 6x50
      iwlwifi: remove unused parameter from iwl_channel_info
      iwlwifi: drop non-production PCI-IDs for 6x50 series
      iwlwifi: remove external reference for non-exist data structure
      iwlwifi: update reply_statistics_cmd with 'clear' parameter
      iwlwifi: eliminate the possible 1/2 dBm tx power loss in 6x00 & 6=
x50 series
      iwlwifi: align tx/rx statistics debugfs format
      iwlwifi: control led while update tx/rx bytes counts
      iwlwifi: set sm_ps_mode as part of cfg parameters
      iwlwifi: reset led_tpt when clear tx/rx traffic byte counts
      iwlwifi: set read/write permission for debugfs files
      iwlwifi: increase tx_queue debugfs buffer size
      iwlwifi: dynamically allocate buffer for sram debugfs file
      iwlwifi: fix reserved2 field in iwl4965_addsta
      iwlwifi: update supported PCI_ID list for 5xx0 series
      iwlwifi: by default, dump entire sram data portion
      iwlwifi: dump error log when uCode error occurred
      iwlwifi: print limited number of event log when uCode error
      iwlwifi: change message for cmd queue full error
      iwlwifi: remove reset led_tpt from iwl_leds_init()

Xose Vazquez Perez (1):
      rt2x00: more ids to rt2800usb.c

 drivers/net/wireless/ath/ar9170/main.c       |    9 +-
 drivers/net/wireless/ath/ar9170/usb.c        |    4 +-
 drivers/net/wireless/ath/ath5k/phy.c         |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h       |   10 -
 drivers/net/wireless/ath/ath9k/common.c      |   19 +-
 drivers/net/wireless/ath/ath9k/common.h      |    1 +
 drivers/net/wireless/ath/ath9k/debug.c       |   11 +-
 drivers/net/wireless/ath/ath9k/hw.c          |   55 +----
 drivers/net/wireless/ath/ath9k/hw.h          |   23 --
 drivers/net/wireless/ath/ath9k/main.c        |  121 +++------
 drivers/net/wireless/ath/ath9k/phy.c         |   90 -------
 drivers/net/wireless/ath/ath9k/phy.h         |    3 -
 drivers/net/wireless/ath/ath9k/rc.c          |   73 +++---
 drivers/net/wireless/ath/ath9k/rc.h          |   18 +-
 drivers/net/wireless/ath/ath9k/virtual.c     |    9 +-
 drivers/net/wireless/ath/ath9k/xmit.c        |   83 +++----
 drivers/net/wireless/ath/regd.c              |    5 +-
 drivers/net/wireless/b43/dma.c               |  264 +++++++++++++++---=
--
 drivers/net/wireless/b43/dma.h               |   13 +-
 drivers/net/wireless/ipw2x00/ipw2100.c       |  130 ++++++++---
 drivers/net/wireless/ipw2x00/ipw2200.c       |  153 +++++++++---
 drivers/net/wireless/ipw2x00/libipw.h        |    8 +-
 drivers/net/wireless/ipw2x00/libipw_module.c |   38 +++-
 drivers/net/wireless/iwlwifi/iwl-1000.c      |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.h      |   11 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c      |   10 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |   55 ++++-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |   38 +---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  322 ++++++++++++++++++=
+------
 drivers/net/wireless/iwlwifi/iwl-calib.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   38 +++-
 drivers/net/wireless/iwlwifi/iwl-core.c      |  106 +++++----
 drivers/net/wireless/iwlwifi/iwl-core.h      |   27 +--
 drivers/net/wireless/iwlwifi/iwl-csr.h       |  181 ++++++++++++---
 drivers/net/wireless/iwlwifi/iwl-debug.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |  171 ++++++++------
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   30 +--
 drivers/net/wireless/iwlwifi/iwl-devtrace.c  |    1 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |   21 ++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |   75 ++++--
 drivers/net/wireless/iwlwifi/iwl-eeprom.h    |    6 +-
 drivers/net/wireless/iwlwifi/iwl-io.h        |   20 ++
 drivers/net/wireless/iwlwifi/iwl-led.c       |    1 -
 drivers/net/wireless/iwlwifi/iwl-power.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |   38 ++--
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   29 +--
 drivers/net/wireless/iwlwifi/iwl-sta.h       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |   61 ++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |   84 +++++--
 drivers/net/wireless/mac80211_hwsim.c        |   18 +-
 drivers/net/wireless/p54/main.c              |    2 +-
 drivers/net/wireless/rndis_wlan.c            |   11 +-
 drivers/net/wireless/rt2x00/rt2800usb.c      |   39 +++-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |   11 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h      |    4 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c      |    5 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c    |    6 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h    |    5 +-
 drivers/net/wireless/wl12xx/wl1251.h         |    5 +
 drivers/net/wireless/wl12xx/wl1251_acx.c     |   68 +++++-
 drivers/net/wireless/wl12xx/wl1251_acx.h     |   36 +++-
 drivers/net/wireless/wl12xx/wl1251_boot.c    |   55 +++-
 drivers/net/wireless/wl12xx/wl1251_event.c   |   15 ++
 drivers/net/wireless/wl12xx/wl1251_init.c    |    8 +-
 drivers/net/wireless/wl12xx/wl1251_main.c    |  162 +++++++-----
 drivers/net/wireless/wl12xx/wl1251_ps.c      |   44 +++-
 drivers/net/wireless/wl12xx/wl1251_ps.h      |    1 +
 drivers/net/wireless/wl12xx/wl1251_reg.h     |    6 +
 drivers/net/wireless/wl12xx/wl1251_rx.c      |    4 -
 drivers/net/wireless/wl12xx/wl1251_spi.c     |    2 +
 drivers/net/wireless/wl3501_cs.c             |    2 +-
 drivers/ssb/main.c                           |  126 +++++-----
 drivers/ssb/scan.c                           |    2 +-
 drivers/ssb/sprom.c                          |   30 ++-
 drivers/ssb/ssb_private.h                    |   12 +-
 include/linux/ieee80211.h                    |   16 ++-
 include/linux/if.h                           |    1 +
 include/linux/rfkill.h                       |    3 +
 include/linux/spi/wl12xx.h                   |    1 +
 include/net/cfg80211.h                       |   85 +++++--
 include/net/mac80211.h                       |   51 +++--
 net/bridge/br_if.c                           |    4 +
 net/mac80211/Makefile                        |    2 +-
 net/mac80211/agg-rx.c                        |    8 +-
 net/mac80211/agg-tx.c                        |  103 ++++-----
 net/mac80211/cfg.c                           |   29 +--
 net/mac80211/debugfs.c                       |    2 +-
 net/mac80211/debugfs_sta.c                   |   29 +++
 net/mac80211/driver-ops.h                    |    5 +-
 net/mac80211/driver-trace.h                  |    9 +-
 net/mac80211/ht.c                            |    5 +-
 net/mac80211/ibss.c                          |    3 +-
 net/mac80211/ieee80211_i.h                   |   30 ++-
 net/mac80211/iface.c                         |   12 +-
 net/mac80211/main.c                          |  343 +-----------------=
--------
 net/mac80211/mesh.c                          |   28 +--
 net/mac80211/mesh.h                          |    4 +-
 net/mac80211/mesh_hwmp.c                     |   24 +-
 net/mac80211/mesh_pathtbl.c                  |    7 +-
 net/mac80211/mesh_plink.c                    |    2 +-
 net/mac80211/mlme.c                          |   30 ++-
 net/mac80211/rate.c                          |   12 +-
 net/mac80211/rate.h                          |    9 +-
 net/mac80211/rx.c                            |  334 +++++++++++++-----=
-------
 net/mac80211/spectmgmt.c                     |    2 +-
 net/mac80211/sta_info.c                      |   36 ++-
 net/mac80211/sta_info.h                      |    6 +-
 net/mac80211/status.c                        |  337 ++++++++++++++++++=
+++++++
 net/mac80211/tkip.c                          |    4 +-
 net/mac80211/tx.c                            |   45 ++--
 net/mac80211/util.c                          |   10 +-
 net/mac80211/wep.c                           |    8 +-
 net/mac80211/wpa.c                           |   25 +-
 net/rfkill/core.c                            |    4 +-
 net/wireless/Kconfig                         |    6 -
 net/wireless/core.c                          |   17 +-
 net/wireless/core.h                          |    2 +
 net/wireless/ibss.c                          |    4 +-
 net/wireless/mlme.c                          |   56 ++++-
 net/wireless/nl80211.c                       |   40 +++-
 net/wireless/reg.c                           |   13 +-
 net/wireless/scan.c                          |   40 ++--
 net/wireless/util.c                          |   36 +++
 net/wireless/wext-compat.c                   |   49 +++-
 125 files changed, 3163 insertions(+), 1936 deletions(-)
 create mode 100644 net/mac80211/status.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-11-24.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
