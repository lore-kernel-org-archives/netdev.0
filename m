From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-01-18
Date: Mon, 18 Jan 2010 17:36:02 -0500
Message-ID: <20100118223602.GA24834@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49010 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab0ARWpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 17:45:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Yikes!!  I guess I fell out of the habit of sending pull requests for
wireless-next-2.6...I'm sorry!  I could send this as a couple of
intermediate pull requests if that would be at all helpful...?  Now tha=
t
I think about it, I guess I was holding back wireless-next-2.6 for a
while because it was broken and I didn't want to "spread the wealth"...
:-)

In any case, this is the usual huge round of updates intended for
2.6.34.  It also includes a couple of merges from wireless-2.6 to
resolve build/merge problems.  This seems like a lot of stuff, but a lo=
t
of it is comprised of mwl8k driver updates and 802.11n phy support
working its way into b43.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 354fcd7774a00809ebefdba75e747364cb22=
a940:
  Michael Chan (1):
        bnx2: Save statistics during reset.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Benoit Papillault (2):
      zd1211rw: Fix multicast filtering.
      mac80211: Fixed netif_tx_wake_all_queues in IBSS mode

Christian Lamparter (1):
      mac80211: fix ampdu_action tx_start ssn

Christoph Egger (1):
      Remove config option B43_LEGACY_RFKILL completely

Dan Carpenter (1):
      iwl: off by one bug

Dominik Geyer (1):
      ath9k: Fix Kconfig depends for ATH9K_DEBUGFS

=46elix Fietkau (6):
      mac80211: use nullfunc frames for 4-addr sta detection
      mac80211: allow station updates on ap interfaces for vlan station=
s
      mac80211: do not transmit frames on unconfigured 4-addr vlan inte=
rfaces
      mac80211: force use_short_slot=3Dtrue for 5GHz
      ath9k: cleanup slot time and ack/cts timeout handling
      ath9k: implement coverage class support

Gertjan van Wingerde (5):
      rt2x00: Fix LED configuration setting for rt2800.
      rt2x00: Properly request tx headroom for alignment operations.
      rt2x00: RF3052 is a valid RF chipset for USB devices as well.
      rt2x00: Unify rt2800 WPDMA ready waiting functions.
      rt2x00: Make rt2800_init_led static and don't export it.

H Hartley Sweeten (1):
      iwl-debugfs.c: remove unnecessary casts of void *

Joe Perches (1):
      net/mac80211/mlme.c: Remove unnecessary semicolons

Johannes Berg (4):
      mac80211: fix skb buffering issue
      mac80211: fix a few work bugs
      mac80211: fix return from ieee80211_assoc_success
      mac80211: remove unused type argument

John W. Linville (7):
      mac80211: fix typo added by "mac80211: fix propagation of failed.=
=2E."
      Merge git://git.kernel.org/.../linville/wireless-2.6
      wireless: fix build breakage when CONFIG_CFG80211_REG_DEBUG not s=
et
      mac80211: fix-up build breakage in 2.6.33
      Revert "mac80211: replace netif_tx_{start,stop,wake}_all_queues"
      Merge git://git.kernel.org/.../linville/wireless-2.6
      Revert "iwmc3200wifi: fix array out-of-boundary access"

Jouni Malinen (5):
      mac80211: No need to include WEXT headers here
      mac80211: Select lowest rate based on basic rate set in AP mode
      cfg80211/mac80211: Use more generic bitrate mask for rate control
      nl80211: New command for setting TX rate mask for rate control
      cfg80211: Store IEs from both Beacon and Probe Response frames

Juha Leppanen (1):
      wl1271: fix timeout in wl1271_top_reg_read

Kalle Valo (20):
      mac80211: fix a warning related to pointer conversion to u64 cook=
ie
      mac80211: fix ieee80211_change_mac() to use struct sockaddr
      mac80211: add functions to create PS Poll and Nullfunc templates
      mac80211: use PS Poll and Nullfunc templates when sending such fr=
ames
      wl1251: get PS Poll and Nullfunc templates from mac80211
      mac80211: create Probe Request template
      mac80211: use Probe Request template when sending a direct scan
      wl1251: cleanup scanning code
      wl1251: get probe request template from mac80211
      wl1251: use mac80211 provided channel parameters in scanning
      wl1251: fix sleep related error paths in wl1251_op_bss_info_chang=
ed()
      mac80211: add U-APSD client support
      mac80211: add debugfs interface for U-APSD queue configuration
      mac80211: create tx handler for dynamic ps
      mac80211: check uapsd state for dynamic power save
      ieee80211: add struct ieee80211_hdr_qos
      wl1251: create qos null data template
      wl1251: add U-APSD support
      mac80211: fix mac80211.h documentation warnings
      mac80211: improve powersave documentation

Larry Finger (1):
      Staging: r8187se: Fix compile error from wireless-testing commit =
7044cc56

Lennert Buytenhek (45):
      mwl8k: fix configure_filter() memory leak on error
      mwl8k: update version number to 0.11
      mwl8k: bail out if there is no AP firmware image support for this=
 chip
      mwl8k: prevent freeing free IRQ if ieee80211_register_hw() fails
      mwl8k: make the tx ring drain status messages somewhat more frien=
dly
      mwl8k: move struct peer_capability_info to its only user
      mwl8k: handle station database update for AP's sta entry via ->st=
a_notify()
      mwl8k: remove mwl8k_vif::bssid, which is now useless
      mwl8k: move ->peer_id from mwl8k_vif to mwl8k_sta
      mwl8k: honor peer rate set
      mwl8k: fix changed flags handling in mwl8k_bss_info_changed()
      mwl8k: add support for 88w8363 in STA mode
      mwl8k: allow setting HT channels
      mwl8k: pass in HT capabilities and rates when associating
      mwl8k: trivial rx-only ampdu implementation
      mwl8k: pass GET_HW_SPEC capability bitmask up the stack
      mwl8k: minor cleanups
      mwl8k: undo transmit queue 0/1 swapping in mwl8k_cmd_set_edca_par=
ams()
      mwl8k: bump the transmit wait timeout to 5 seconds
      mwl8k: simplify mwl8k_cmd_use_fixed_rate()
      mwl8k: add the AP version of USE_FIXED_RATE
      mwl8k: implement AP firmware station database maintenance
      mwl8k: correctly set the mac_type field for AP SET_MAC_ADDR
      mwl8k: basic AP interface support
      mwl8k: allow limiting the amount of transmit reclaim done
      mwl8k: keep TX_DONE interrupt masked while transmit reclaim is ru=
nning
      mwl8k: move receive processing to tasklet
      mac80211: flush workqueue before calling driver ->stop() method
      mwl8k: update MODULE_FIRMWARE tags
      mwl8k: remove (mostly) write-only variable priv->current_channel
      mwl8k: don't call SET_AID if we're not associated
      mwl8k: simplify sequence number assignment
      mwl8k: add another 88w8366 PCI ID
      mwl8k: rename 2.4 GHz band/channels/rates related variables from =
=46OO to FOO_24
      mwl8k: move responsibility for initialising wiphy bands to GET_HW=
_SPEC
      mwl8k: add 5 GHz band channels and rates
      mwl8k: properly set receive status rate index on 5 GHz receive
      mwl8k: handle 5 GHz legacy rate bitmaps in firmware commands
      mwl8k: allow selecting 5 GHz channels
      mwl8k: use firmware capability field to decide which bands to reg=
ister
      mwl8k: convert the priv->vif pointer to a list of vifs
      mwl8k: prepare for posting per-vif firmware commands
      mwl8k: post per-vif firmware commands as per-vif commands
      mwl8k: enable multi-BSS AP operation
      mwl8k: update version number (to 0.12) and copyright

Luis R. Rodriguez (11):
      ath5k: Fix eeprom checksum check for custom sized eeproms
      cfg80211: fix syntax error on user regulatory hints
      cfg80211: add a regulatory debug print
      ath9k: re-enable ps by default for new single chip families
      cfg80211: add debug print when we drop a bogus country IE
      cfg80211: process the max power on a country IE
      cfg80211: Fix country IE parsing for single channel triplets
      cfg80211: fix 2 GHz subband calculation for country IEs
      wl1271: remove unused flags
      cfg80211: Ingore country IEs with a zero set of number of channel=
s
      cfg80211: make regulatory_hint_11d() band specific

Luk=C3=A1=C5=A1 Turek (5):
      nl80211: Add new WIPHY attribute COVERAGE_CLASS
      mac80211: Add new callback set_coverage_class
      ath5k: Fix functions for getting/setting slot time
      ath5k: Reimplement clock rate to usec conversion
      ath5k: Implement mac80211 callback set_coverage_class

Ming Lei (2):
      ath9k: fix ito64
      mac80211: fix memory leak in ieee80211_send_probe_req

Pavel Roskin (1):
      rt2x00: use correct headroom for transmission

Rafa=C5=82 Mi=C5=82ecki (33):
      b43: LP-PHY: note and explain specs inconsistency
      b43: use standard fls for finding the most significant bit
      b43: add new SSB's core id for BCM4328
      b43: N-PHY: clean table init, check PHY rev
      b43: N-PHY: add shared memory offsets definitions
      b43: N-PHY: add needed struct definitions
      b43: N-PHY: add missing register definitions
      b43: N-PHY: add global variables to b43_phy_n struct
      b43: N-PHY: add various tables
      b43: N-PHY: update init code to match current specs
      b43: N-PHY: update CCA reset
      b43: N-PHY: split RSSI calibration into 2 functions (rev2, rev3)
      b43: N-PHY: add clip detection reading/writing and some classifie=
r function
      b43: N-PHY: implement RSSI selection and offset scaling
      b43: N-PHY: add RSSI polling and setting 2055 (radio) VCM
      b43: N-PHY: RSSI calibration for rev < 3
      b43: N-PHY: implement PA overriding (RF control related)
      b43: N-PHY: add RSSI calibration restore
      b43: N-PHY: add function than forces (not) staying in carrier sea=
rch
      b43: N-PHY: implement RX IQ coeffs
      b43: N-PHY: implement workaround for TX IQ
      b43: N-PHY: implement restoring general configuration
      b43: N-PHY: implement RX IQ estimation
      b43: N-PHY: implement calculating RX IQ comp
      b43: N-PHY: implement getting TX gains
      b43: N-PHY: add TX LP FBW (TX filter 40 related)
      b43: N-PHY: add RX radio cores calibration
      b43: N-PHY: update TX calibration ladder
      b43: N-PHY: implement calculating IQ gain params
      b43: N-PHY: add huge calculating TX IQ LO
      b43: N-PHY: add RX IQ calibrationi for rev < 3
      b43: N-PHY: implement TX power control coef setup
      b43: N-PHY: drop unused definition, uncomment needed call

Sujith (8):
      ath9k: Add a new file for GPIO
      ath9k: Add new file init.c
      ath9k: Cleanup Powersave flags
      ath9k: Cleanup init/deinit routines
      ath9k: Fix queue handling
      ath9k: Add debugfs file for RX errors
      ath9k: Fix monitor mode handling
      ath9k: Fix panic on driver load

Tim Gardner (2):
      b43: Declare at least one real firmware file using MODULE_FIRMWAR=
E.
      b43legacy: Declare all possible ucodeX.fw files

Wey-Yi Guy (4):
      iwlwifi: add IEEE80211_AMPDU_TX_OPERATIONAL
      iwlwifi: ucode statistics data structure update
      iwlwifi: remove obsoleted host command
      iwlwifi: fix bug in tx byte count table

Zhu Yi (2):
      iwlwifi: remove linux/utsrelease.h dependency
      mac80211: quit addba_resp_timer if Tx BA session is torn down

 Documentation/DocBook/mac80211.tmpl                |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   24 +-
 drivers/net/wireless/ath/ath5k/base.c              |   22 +
 drivers/net/wireless/ath/ath5k/eeprom.c            |   32 +-
 drivers/net/wireless/ath/ath5k/eeprom.h            |    8 +
 drivers/net/wireless/ath/ath5k/pcu.c               |  121 ++-
 drivers/net/wireless/ath/ath5k/qcu.c               |   20 +-
 drivers/net/wireless/ath/ath5k/reset.c             |    9 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    2 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    2 +
 drivers/net/wireless/ath/ath9k/ahb.c               |   23 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   76 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    3 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  118 ++
 drivers/net/wireless/ath/ath9k/debug.h             |   32 +
 drivers/net/wireless/ath/ath9k/gpio.c              |  428 +++++
 drivers/net/wireless/ath/ath9k/hw.c                |  110 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    7 +-
 drivers/net/wireless/ath/ath9k/init.c              |  861 ++++++++++
 drivers/net/wireless/ath/ath9k/mac.h               |   34 +
 drivers/net/wireless/ath/ath9k/main.c              | 1326 +-----------=
---
 drivers/net/wireless/ath/ath9k/pci.c               |   58 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   38 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   18 +-
 drivers/net/wireless/b43/b43.h                     |    8 +
 drivers/net/wireless/b43/main.c                    |    8 +-
 drivers/net/wireless/b43/phy_lp.c                  |   24 +-
 drivers/net/wireless/b43/phy_n.c                   | 1795 ++++++++++++=
+++++++-
 drivers/net/wireless/b43/phy_n.h                   |   87 +-
 drivers/net/wireless/b43/tables_nphy.c             |  577 ++++++-
 drivers/net/wireless/b43/tables_nphy.h             |   71 +-
 drivers/net/wireless/b43legacy/main.c              |   11 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |    3 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    7 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   49 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    1 -
 drivers/net/wireless/iwmc3200wifi/iwm.h            |    2 +-
 drivers/net/wireless/mwl8k.c                       | 1363 +++++++++++-=
---
 drivers/net/wireless/rt2x00/rt2800lib.c            |   29 +-
 drivers/net/wireless/rt2x00/rt2800lib.h            |    3 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   24 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   22 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    6 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    6 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.c           |   83 +
 drivers/net/wireless/wl12xx/wl1251_cmd.h           |   22 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |  291 +---
 drivers/net/wireless/wl12xx/wl1271_reg.h           |   99 --
 drivers/net/wireless/wl12xx/wl1271_spi.c           |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   13 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211.h    |    9 -
 .../rtl8187se/ieee80211/ieee80211_softmac.c        |   24 +-
 drivers/staging/rtl8187se/r8180_core.c             |    4 +-
 include/linux/ieee80211.h                          |   37 +
 include/linux/nl80211.h                            |   58 +-
 include/net/cfg80211.h                             |   31 +-
 include/net/mac80211.h                             |  151 ++-
 net/mac80211/agg-tx.c                              |    5 +-
 net/mac80211/cfg.c                                 |   65 +-
 net/mac80211/debugfs.c                             |   94 +
 net/mac80211/debugfs_netdev.c                      |   44 +-
 net/mac80211/driver-ops.h                          |   15 +
 net/mac80211/driver-trace.h                        |   23 +
 net/mac80211/ieee80211_i.h                         |   31 +-
 net/mac80211/iface.c                               |   56 +-
 net/mac80211/main.c                                |    7 +-
 net/mac80211/mlme.c                                |  104 +-
 net/mac80211/offchannel.c                          |    8 +-
 net/mac80211/rate.c                                |   88 +-
 net/mac80211/rate.h                                |    5 +-
 net/mac80211/rx.c                                  |   16 +-
 net/mac80211/scan.c                                |   20 +-
 net/mac80211/sta_info.c                            |   21 +
 net/mac80211/sta_info.h                            |    3 +
 net/mac80211/tx.c                                  |  278 +++-
 net/mac80211/util.c                                |   60 +-
 net/mac80211/wme.c                                 |   96 +-
 net/mac80211/wme.h                                 |    8 +-
 net/mac80211/work.c                                |   28 +-
 net/wireless/core.c                                |    1 +
 net/wireless/core.h                                |    3 +-
 net/wireless/nl80211.c                             |  130 ++
 net/wireless/reg.c                                 |  319 ++++-
 net/wireless/reg.h                                 |   11 +
 net/wireless/scan.c                                |  120 +-
 net/wireless/sme.c                                 |    1 +
 net/wireless/wext-compat.c                         |   34 +-
 92 files changed, 7260 insertions(+), 2757 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/gpio.c
 create mode 100644 drivers/net/wireless/ath/ath9k/init.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-01-18.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
