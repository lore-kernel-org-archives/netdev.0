From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-04-15
Date: Thu, 15 Apr 2010 16:53:59 -0400
Message-ID: <20100415205358.GA6659@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53823 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756921Ab0DOVAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 17:00:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another huge dump of wireless bits intended for 2.6.35...  It i=
s
mostly drivers, and mostly the "usual suspects" of those -- ath5k,
ath9k, iwlwifi, rt2x00, wl1271, and others.  There are also some
infrastructure bits from Johannes and Jouni, including some tracing
stuff.

Please let me know if there are problems!

Thanks,

John

P.S.  Please note the "for-davem" after the git url... :-)

---

The following changes since commit fea069152614cdeefba4b2bf80afcddb9c21=
7fc8:
  David S. Miller (1):
        Merge branch 'vhost' of git://git.kernel.org/.../mst/vhost

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Bob Copeland (4):
      ath5k: correct channel setting for 2.5 mhz spacing
      ath5k: clean up queue manipulation
      ath5k: fix race condition in tx desc processing
      ath5k: add bounds check to pdadc table

Bruno Randolf (12):
      ath5k: remove static calibration interval variable
      ath5k: remove the use of SWI interrupt
      ath5k: optimize ath5k_hw_calibration_poll
      ath5k: move ath5k_hw_calibration_poll to base.c
      ath5k: keep beacon RSSI average
      ath5k: initialize default noise floor
      ath5k: simplify MIB counters
      ath5k: update phy errors codes
      ath5k: add capability flag for phyerror counters
      ath5k: Adaptive Noise Immunity (ANI) Implementation
      ath5k: Use high bitrates for ACK/CTS
      ath5k: treat RXORN as non-fatal

Christian Lamparter (2):
      ar9170usb: fix panic triggered by undersized rxstream buffer
      ar9170usb: add a couple more USB IDs

Daniel Mack (1):
      libertas/sdio: 8686: set ECSI bit for 1-bit transfers

=46elix Fietkau (4):
      ath9k: split out access to tx status information
      ath9k: split out access to rx status information
      ath9k: allocate tx and rx status information on stack
      ath9k: fix compile error without debug enabled

=46rans Pop (7):
      wireless: remove trailing space in messages
      wireless/prism54: remove trailing space in messages
      wireless/raylink: remove trailing space in messages
      wireless/libertas: remove trailing space in debugfs header
      wireless/ipw2x00: remove trailing space in messages
      iwlwifi: remove trailing space in messages
      wireless/ath: remove trailing space in messages

Gertjan van Wingerde (13):
      rt2x00: Disable auto wakeup before waking up device.
      rt2x00: Add wakeup interrupt handler to rt61pci.
      rt2x00: Add wakeup interrupt handler to rt2800pci.
      rt2x00: Enable powersaving by default again on rt2500usb.
      rt2x00: Let RF chipset decide the RF channel switch method to use=
 in rt2800.
      rt2x00: Update rt2800 register definitions towards latest definit=
ions.
      rt2x00: Align RT chipset definitions with vendor driver.
      rt2x00: Refactor rt2800 version constants.
      rt2x00: Align rt2800 register initialization with vendor driver.
      rt2x00: Finish rt3070 support in rt2800 register initialization.
      rt2x00: Add rt3071 support in rt2800 register initialization.
      rt2x00: Add rt3090 support in rt2800 register initialization.
      rt2x00: Add rt3390 support in rt2800 register initialization.

Grazvydas Ignotas (1):
      wl1251: don't require NVS data when EEPROM is used

Helmut Schaa (1):
      rt2x00: use rt2800_config_channel_rt3x for rt2872

Javier Cardona (1):
      mac80211: Moved mesh action codes to a more visible location

Jay Sternberg (1):
      iwlwifi: enable '6000 Series 2x2 AGN Gen2' adaptors

Joe Perches (1):
      include/net/iw_handler.h: Use SIOCIWFIRST not SIOCSIWCOMMIT in co=
mment

Johannes Berg (14):
      iwlwifi: remove noise reporting
      mac80211: fix station destruction problem
      mac80211: remove irq disabling for sta lock
      mac80211: remove ieee80211_sta_stop_rx_ba_session
      mac80211: rename WLAN_STA_SUSPEND to WLAN_STA_BLOCK_BA
      mac80211: clean up/fix aggregation code
      mac80211: fix some RX aggregation locking
      mac80211: fix paged RX crypto
      mac80211: enhance tracing
      iwlwifi: make WEP key restoring explicit
      iwlwifi: remove wrong key use check
      iwlagn: simplify WEP key check
      iwlwifi: remove pointless sta_id invalid check
      iwlwifi: clean up last_phy_res

John W. Linville (6):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into merge
      ath5k: fixup some merge damage for AR5211 IQ calibration
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Jouni Malinen (8):
      mac80211: Track Beacon signal strength and implement cqm events
      mac80211: Send deauth/disassoc prior to dropping STA entry
      mac80211: Fix BIP to be used only with group-addressed frames
      mac80211: Fix dropping of unprotected robust multicast frames
      ath9k: Do not indicate RX_FLAG_DECRYPTED for unprotected frames
      mac80211: Fix drop_unencrypted for MFP with hwaccel
      mac80211: Fix robust management frame handling (MFP)
      cfg80211: Add local-state-change-only auth/deauth/disassoc

Juuso Oikarinen (26):
      wl1271: Clean up RX rate reporting
      wl1271: Add TX rate reporting
      wl1271: Fix memory leaks in SPI initialization
      wl1271: Fix memory leak in scan command handling
      wl1271: Configure clock-request drive mode to open-drain
      wl1271: Fix memory leak in cmd_data_path
      wl1271: Update busyword checking mechanism
      wl1271: Remove device MAC-address randomization
      wl1271: Disable connection monitoring while not associated
      wl1271: Fix ad-hoc mode handling
      wl1271: Update beacon interval properly for ad-hoc
      wl1271: Fix memory leak in firmware crash scenario
      wl1271: Configure probe-request template when associated
      wl1271: Disconnect if PSM entry fails
      wl1271: Configure HW connection monitor
      wl1271: Add keep-alive frame template support
      wl1271: Enable hardware keep alive messages
      wl1271: Fix keep-alive related command error
      wl1271: Use minimum rate for each band for control messages
      wl1271: Configure rates for templates
      wl1271: Configure a higher listen interval to AP upon association
      wl1271: Fix debug prints for beacon-loss and psm-entry-fail scena=
rios
      wl1271: Fix tx queue flushing
      wl1271: Fix memory leaks on driver initialization
      wl1271: Go to ELP in idle
      wl1271: Add support for connection quality monitoring

Kalle Valo (1):
      wl1251: use DRIVER_NAME macro in wl1251_spi_driver

Luciano Coelho (6):
      wl1271: fix wl1271_spi driver name
      wl1271: wait for join command complete event
      wl1271: wait for disconnect command complete event
      wl1271: remove deprecated usage of RX status noise
      wl1271: fix sdio driver name in wl1271_sdio_driver
      wl1271: added missing command header in wl1271_cmd_disconnect

Luis Correia (1):
      rt2x00: remove MCU requests for SoC platforms

Luis R. Rodriguez (2):
      mac80211_hwsim: add sw_scan sw_scan_complete
      mac80211: fix typo for LDPC capability

Luis de Bethencourt (3):
      Net: wireless: ath: fix macros coding style issue in hw.c
      ath: fix code readability in regd.c
      ath: fix coding style/readability in ath/ar9170

Marco Porsch (1):
      nl80211: reenable station del for mesh

Ming Lei (4):
      ath9k-htc:respect usb buffer cacheline alignment in ath9k_hif_usb=
_alloc_rx_urbs
      ath9k-htc:respect usb buffer cacheline alignment in reg in path
      ath9k-htc:respect usb buffer cacheline alignment in reg out path
      ath9k-htc: fix lockdep warning and kernel warning after unpluggin=
g ar9271 usb device

Pavel Roskin (4):
      ath9k: rename symbols in enum ath9k_internal_frame_type to avoid =
confusion
      ath9k: move imask from sc to ah
      ath9k: remove ah->mask_reg, it's never used properly
      ath9k: simplify AR9220 fixup code for AR_AN_TOP2 register

Quintin Pitts (1):
      p54pci: prevent stuck rx-ring on slow system

Rafa=C5=82 Mi=C5=82ecki (6):
      b43: N-PHY: some dummy PHY rev 3 calls
      b43: N-PHY: use b43_phy_n_sfo_cfg rather than duplicating same fi=
elds
      b43: N-PHY: find table entry earlier for setting chanspec
      b43: N-PHY: prepare for rev3+ channel tables
      b43: N-PHY: fix value written on 2055 radio setup
      b43: N-PHY: fix copy&paste typo

Reinette Chatre (2):
      Revert "iwlwifi: fix build error for CONFIG_IWLAGN=3Dn"
      iwlwifi: fix compile warnings when compiling without debug

Saravanan Dhanabal (3):
      wl1271: Fix msleep() delay while waiting for completion
      wl1271: Fix mac80211 configuration requests during WL1271_STATE_O=
=46F
      wl1271: Fix mac80211 RTS threshold requests during WL1271_STATE_O=
=46F

Stanislaw Gruszka (3):
      mac80211: explicitly disable/enable QoS
      iwlwifi: manage QoS by mac stack
      mac80211: enable QoS explicitly in AP mode

Sujith (15):
      ath9k_common: Move RX filter code to ath9k_htc
      ath9k_htc: Fix bug in aggregation initiation
      ath9k_htc: Fix watchdog pattern parsing
      ath9k_htc: Simplify RX URB management
      ath9k_htc: Handle TX queue overflow
      ath9k_htc: Initialize HW opmode
      ath9k_htc: Fix TKIP encryption
      ath: Add a bus type field
      ath9k_hw: Don't check devid for ath9k_htc
      ath9k_htc: Add TL-WN422G v2 product ID
      ath9k_htc: Protect RX stream variables
      ath9k_htc: Fix RX URB reference count
      ath9k_htc: Fix module unloading issue
      ath9k_htc: Use anchors for REGOUT pipe
      ath9k_htc: Fix HTC layer memleak

Teemu Paasikivi (3):
      wl1271: Warnings caused by wrong format specifiers fixed
      wl1271: Removed checking of PSM from handling BSS_LOST_EVENT
      mac80211: check whether scan is in progress before queueing scan_=
work

Vivek Natarajan (3):
      ath9k: Add support for newer AR9285 chipsets.
      ath9k_htc: Add support for power save.
      ath9k_htc: Configure the beacon timers once the scan is completed=
=2E

Wey-Yi Guy (28):
      iwlwifi: iwl_good_ack_health() only apply to AGN device
      iwlwifi: move ucode loading related code to separated file
      iwlwifi: code cleanup for "load ucode" function
      iwlwifi: move hcmd related code to separate file
      iwlwifi: move tx queue related code to separate file
      iwlwifi: move hw related defines to separate file
      iwlwifi: move ucode alive related code to separate file
      iwlwifi: move agn common code to iwlagn library file
      iwlwifi: each device has its own eeprom tx power version
      iwlwifi: move agn module parameter structure to common place
      iwlwifi: move agn only tx functions from iwlcore to iwlagn
      iwlwifi: move agn only rx functions from iwlcore to iwlagn
      iwlwifi: more clean up to move agn only rx functions from iwlcore=
 to iwlagn
      iwlwifi: remove non-exist extern functions and structures
      iwlwifi: add missing email address information
      iwlwifi: Generic approach to measure temperature
      iwlwifi: remove "\n" from module parameter description
      iwlwifi: change spin_lock to spin_lock_irqsave
      iwlwifi: avoid device type checking in generic code
      iwlwifi: merge module parameters into single place
      iwlwifi: remove irrelevant comments
      iwlwifi: deprecate "iwl4965" alias support
      iwlwifi: code cleanup for generic defines
      iwlwifi: default max event log size
      iwlwifi: add more debug info in error event dump
      iwlwifi: update tx command response status
      iwlwifi: small changes in comments
      iwlwifi: fix compiler warning

Xose Vazquez Perez (5):
      wireless: rt2x00: rt2800usb: identify ids-chips
      wireless: rt2x00: rt2800usb: delete id
      wireless: rt2x00: rt2800pci: new id
      wireless: rt2x00: rt2800usb: new ids
      wireless: rt2x00: rt2800usb: identify Sitecom devices

Zhu Yi (6):
      mac80211: support paged rx SKBs
      iwlwifi: remove skb_linearize for rx frames
      ipw2200: restart adapter only when abort_scan doesn't work
      iwlwifi: clear rxq->queue in queue reset
      mac80211: delay skb linearising in rx decryption
      iwlwifi: avoid Tx queue memory allocation in interface down

 Documentation/feature-removal-schedule.txt      |   22 +-
 drivers/net/wireless/ath/ar9170/cmd.h           |    2 +-
 drivers/net/wireless/ath/ar9170/eeprom.h        |    4 +-
 drivers/net/wireless/ath/ar9170/hw.h            |    1 +
 drivers/net/wireless/ath/ar9170/main.c          |   13 +-
 drivers/net/wireless/ath/ar9170/usb.c           |   10 +
 drivers/net/wireless/ath/ath.h                  |   13 +-
 drivers/net/wireless/ath/ath5k/Makefile         |    1 +
 drivers/net/wireless/ath/ath5k/ani.c            |  744 ++++++++++++
 drivers/net/wireless/ath/ath5k/ani.h            |  104 ++
 drivers/net/wireless/ath/ath5k/ath5k.h          |   68 +-
 drivers/net/wireless/ath/ath5k/attach.c         |    2 +
 drivers/net/wireless/ath/ath5k/base.c           |  129 ++-
 drivers/net/wireless/ath/ath5k/base.h           |   21 +-
 drivers/net/wireless/ath/ath5k/caps.c           |    6 +
 drivers/net/wireless/ath/ath5k/debug.c          |  170 +++
 drivers/net/wireless/ath/ath5k/debug.h          |    2 +
 drivers/net/wireless/ath/ath5k/desc.c           |    1 +
 drivers/net/wireless/ath/ath5k/desc.h           |   35 +-
 drivers/net/wireless/ath/ath5k/pcu.c            |   44 +-
 drivers/net/wireless/ath/ath5k/phy.c            |   37 +-
 drivers/net/wireless/ath/ath5k/reg.h            |   40 +-
 drivers/net/wireless/ath/ath9k/ahb.c            |    1 +
 drivers/net/wireless/ath/ath9k/ath9k.h          |    4 -
 drivers/net/wireless/ath/ath9k/beacon.c         |   35 +-
 drivers/net/wireless/ath/ath9k/calib.c          |   59 +-
 drivers/net/wireless/ath/ath9k/common.c         |   85 +--
 drivers/net/wireless/ath/ath9k/common.h         |    4 -
 drivers/net/wireless/ath/ath9k/debug.c          |   39 +-
 drivers/net/wireless/ath/ath9k/debug.h          |    9 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c    |    2 +-
 drivers/net/wireless/ath/ath9k/gpio.c           |   17 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c        |  191 ++--
 drivers/net/wireless/ath/ath9k/hif_usb.h        |   10 +-
 drivers/net/wireless/ath/ath9k/htc.h            |   25 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |   41 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |   12 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c   |  149 +++-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c   |  112 ++-
 drivers/net/wireless/ath/ath9k/htc_hst.c        |   35 +-
 drivers/net/wireless/ath/ath9k/hw.c             |  139 +--
 drivers/net/wireless/ath/ath9k/hw.h             |    5 +-
 drivers/net/wireless/ath/ath9k/initvals.h       |  109 ++-
 drivers/net/wireless/ath/ath9k/mac.c            |  149 ++--
 drivers/net/wireless/ath/ath9k/mac.h            |   14 +-
 drivers/net/wireless/ath/ath9k/main.c           |   60 +-
 drivers/net/wireless/ath/ath9k/pci.c            |    1 +
 drivers/net/wireless/ath/ath9k/phy.h            |   14 +-
 drivers/net/wireless/ath/ath9k/rc.h             |    6 +-
 drivers/net/wireless/ath/ath9k/recv.c           |   26 +-
 drivers/net/wireless/ath/ath9k/reg.h            |   13 +-
 drivers/net/wireless/ath/ath9k/virtual.c        |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c            |   10 +-
 drivers/net/wireless/ath/ath9k/xmit.c           |  113 +-
 drivers/net/wireless/ath/hw.c                   |    4 +-
 drivers/net/wireless/ath/regd.c                 |    3 +-
 drivers/net/wireless/b43/phy_n.c                |   54 +-
 drivers/net/wireless/b43/tables_nphy.c          |   20 +-
 drivers/net/wireless/b43/tables_nphy.h          |   28 +-
 drivers/net/wireless/ipw2x00/ipw2100.c          |   38 +-
 drivers/net/wireless/ipw2x00/ipw2200.c          |   87 +-
 drivers/net/wireless/iwlwifi/Makefile           |    2 +
 drivers/net/wireless/iwlwifi/iwl-1000.c         |   78 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h      |    5 -
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c         |   79 +--
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h      |   24 -
 drivers/net/wireless/iwlwifi/iwl-4965.c         |   62 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h      |   33 -
 drivers/net/wireless/iwlwifi/iwl-5000.c         | 1378 ++-------------=
--------
 drivers/net/wireless/iwlwifi/iwl-6000.c         |  195 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c     |  274 +++++
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h       |  118 ++
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c      |   14 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c      | 1113 +++++++++++++++=
+++
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c       | 1333 +++++++++++++++=
+++++++
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c    |  416 +++++++
 drivers/net/wireless/iwlwifi/iwl-agn.c          |  204 +++--
 drivers/net/wireless/iwlwifi/iwl-agn.h          |  100 ++
 drivers/net/wireless/iwlwifi/iwl-calib.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h     |  108 ++-
 drivers/net/wireless/iwlwifi/iwl-core.c         |  267 +----
 drivers/net/wireless/iwlwifi/iwl-core.h         |   31 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h          |   76 +--
 drivers/net/wireless/iwlwifi/iwl-devtrace.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h       |   17 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-io.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c        |   10 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c           |  758 +-------------
 drivers/net/wireless/iwlwifi/iwl-scan.c         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c          |   48 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c           | 1091 +--------------=
----
 drivers/net/wireless/iwlwifi/iwl3945-base.c     |   30 +-
 drivers/net/wireless/libertas/debugfs.c         |    2 +-
 drivers/net/wireless/libertas/if_sdio.c         |   22 +
 drivers/net/wireless/mac80211_hwsim.c           |   45 +-
 drivers/net/wireless/p54/p54pci.c               |   26 +-
 drivers/net/wireless/p54/txrx.c                 |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c       |   16 +-
 drivers/net/wireless/prism54/islpci_eth.c       |    8 +-
 drivers/net/wireless/prism54/islpci_mgt.c       |    8 +-
 drivers/net/wireless/prism54/oid_mgt.c          |    2 +-
 drivers/net/wireless/ray_cs.c                   |   12 +-
 drivers/net/wireless/rt2x00/rt2400pci.c         |    4 +
 drivers/net/wireless/rt2x00/rt2500pci.c         |    4 +
 drivers/net/wireless/rt2x00/rt2500usb.c         |    9 +-
 drivers/net/wireless/rt2x00/rt2800.h            |  108 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c         |  467 ++++++---
 drivers/net/wireless/rt2x00/rt2800pci.c         |   31 +-
 drivers/net/wireless/rt2x00/rt2800usb.c         |   76 +-
 drivers/net/wireless/rt2x00/rt2x00.h            |   29 +-
 drivers/net/wireless/rt2x00/rt61pci.c           |   14 +
 drivers/net/wireless/rt2x00/rt73usb.c           |    6 +-
 drivers/net/wireless/wl12xx/wl1251_main.c       |    4 +-
 drivers/net/wireless/wl12xx/wl1251_spi.c        |    2 +-
 drivers/net/wireless/wl12xx/wl1271.h            |   19 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c        |  146 +++-
 drivers/net/wireless/wl12xx/wl1271_acx.h        |   89 ++-
 drivers/net/wireless/wl12xx/wl1271_boot.c       |   15 +-
 drivers/net/wireless/wl12xx/wl1271_boot.h       |    7 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c        |  127 ++-
 drivers/net/wireless/wl12xx/wl1271_cmd.h        |   13 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h       |  158 ++--
 drivers/net/wireless/wl12xx/wl1271_event.c      |   66 +-
 drivers/net/wireless/wl12xx/wl1271_event.h      |    8 +
 drivers/net/wireless/wl12xx/wl1271_init.c       |   53 +-
 drivers/net/wireless/wl12xx/wl1271_main.c       |  393 ++++++--
 drivers/net/wireless/wl12xx/wl1271_ps.c         |    6 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c         |   83 +--
 drivers/net/wireless/wl12xx/wl1271_rx.h         |    2 +-
 drivers/net/wireless/wl12xx/wl1271_sdio.c       |    6 +-
 drivers/net/wireless/wl12xx/wl1271_spi.c        |   71 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c         |   43 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h         |    2 +
 include/linux/ieee80211.h                       |    3 +-
 include/linux/mmc/sdio.h                        |    2 +
 include/linux/nl80211.h                         |    8 +
 include/net/cfg80211.h                          |   11 +
 include/net/iw_handler.h                        |    2 +-
 include/net/mac80211.h                          |   10 +-
 net/mac80211/Kconfig                            |    8 +-
 net/mac80211/agg-rx.c                           |   72 +-
 net/mac80211/agg-tx.c                           |   14 +-
 net/mac80211/cfg.c                              |   13 +-
 net/mac80211/debugfs_netdev.c                   |   12 +
 net/mac80211/debugfs_sta.c                      |   12 +-
 net/mac80211/driver-trace.h                     |  275 +++++
 net/mac80211/ht.c                               |    3 +-
 net/mac80211/ieee80211_i.h                      |   21 +-
 net/mac80211/main.c                             |    2 +
 net/mac80211/mesh.c                             |    4 +-
 net/mac80211/mesh.h                             |    2 -
 net/mac80211/mesh_hwmp.c                        |    4 +-
 net/mac80211/mesh_plink.c                       |    2 +-
 net/mac80211/mlme.c                             |  106 ++-
 net/mac80211/pm.c                               |    2 +-
 net/mac80211/rx.c                               |   91 ++-
 net/mac80211/scan.c                             |    2 +
 net/mac80211/sta_info.c                         |   75 +-
 net/mac80211/sta_info.h                         |   10 +-
 net/mac80211/tx.c                               |    7 +-
 net/mac80211/util.c                             |   11 +-
 net/mac80211/work.c                             |    7 +-
 net/wireless/core.h                             |   15 +-
 net/wireless/mlme.c                             |   39 +-
 net/wireless/nl80211.c                          |   22 +-
 net/wireless/reg.c                              |    6 +-
 net/wireless/sme.c                              |   15 +-
 net/wireless/util.c                             |   24 +-
 174 files changed, 8596 insertions(+), 5612 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath5k/ani.c
 create mode 100644 drivers/net/wireless/ath/ath5k/ani.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-hw.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-lib.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-tx.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-04-15.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
