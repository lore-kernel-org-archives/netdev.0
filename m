From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-04-24
Date: Fri, 24 Apr 2009 16:05:05 -0400
Message-ID: <20090424200504.GC3309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37070 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbZDXUPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 16:15:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a huge pull request for net-next-2.6, the first one this
cycle.  There is the usual huge round of driver and mac80211 updates.
Among other things is some movement of code to enable sharing some bits
between ath5k, ath9k, and ar9170.  Also included is the beginngin of
migration of rndis_wlan to the cfg80211 API, the first non-mac80211
driver to do that.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6/

---

The following changes since commit 4cb9be7ab47820a1fa747569f5f035a5f628=
c91b:
  Jesse Brandeburg (1):
        e1000/e1000e/igb/ixgb: do not use netif_wake_queue un-necessari=
ly

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Abhijeet Kolekar (22):
      iwl3945: use iwl_mac_conf_tx
      iwl3945: use iwl_bss_info_changed
      iwl3945: use iwl_mac_beacon_update
      iwlwifi: add commit_rxon lib
      iwl3945: delay mode setting
      iwlwifi: add station management ops
      iwl3945: replace station function with station ops
      iwlwifi: use station management ops
      iwl3945/iwlwifi: unify add_station function
      iwl3945: use iwl_get_sta_id from iwlwifi
      iwlwifi: add set_rxon_chain op
      iwl3945: use iwl_set_mode in 3945
      iwl3945: use iwl_mac_add_interface from iwlwifi
      iwl3945: use iwl_mac_remove_interface from iwlwifi
      iwl3945: use iwl_mac_config from iwlwifi
      iwlwifi: add config_ap lib op
      iwl3945: use iwl_mac_config_interface from iwlwifi
      iwl3945: use iwl_mac_get_tx_stats from iwlwifi
      iwl3945: use iwl_mac_reset_tsf from iwlwifi
      iwl3945: add debugfs to 3945
      iwl3945: calculate debugfs isr statistics
      iwlwifi: remove radio disable parameter.

Anna Neal (1):
      libertas: increase spi driver thread priority

Bing Zhao (2):
      libertas: support mesh for various firmware versions
      libertas: add support for Marvell SD8688 chip

Bob Copeland (12):
      ath5k: reduce exported channel list
      ath9k: separate ath9k specific code from ath9k_regd_get_ctl()
      ath9k: pass regd structure directly to regulatory functions
      atheros: introduce ath module containing common ath5k/ath9k/ar917=
0 code
      ath: move more setup code into ath_regd_init
      ath5k: use regulatory infrastructure
      ath5k: add support for Fukato Datacask Jupiter LEDs
      ath5k: fix initvals errors
      ath5k: use tasklet_hi_schedule for beacon queue
      ath5k: use bool for modparams
      ath5k: use rx hw descriptor pointer for self-linked check
      ath5k: manipulate rxlink and descriptor address under rxbuf lock

Christian Lamparter (13):
      ar9170: fix hang on stop
      p54: clean up p54.h's struct p54_common
      p54: more SoftLED updates
      p54: add beacon filtering support
      Make ar9170 use common ath reg code
      p54: utilize all available key slots for decryption offload
      p54: remove obsolet signal quality calculation
      ath: add module information
      p54: remove module_ stubs
      p54: deactivate broken powersave function (part 2)
      p54: fix ps-poll delivery in ap mode
      mac80211: set CLEAR_PS for pspolled frames
      ar9170: rework rxstream code

Daniel C Halperin (2):
      iwlwifi: do not set dual_stream_ant_msk for 3 streams
      iwlwifi: check triple_stream_basic_rates in iwl_full_rxon_require=
d

=46abio Rossi (1):
      ath5k: fix interpolation with equal power levels

G=E1bor Stefanik (1):
      rtl8187: Remove the "8187B chip detected" message when probing RT=
L8187B cards

Huang Weiyi (2):
      cfg80211: remove duplicated #include
      nl80211: remove duplicated #include

Ivo van Doorn (2):
      rt2x00: Move Move pci_dev specific access to rt2x00pci
      rt2x00: Fix Sparse warning

Johannes Berg (37):
      nl80211: validate some input better
      rfkill: remove deprecated state constants
      rfkill: remove user_claim stuff
      rfkill-input: remove unused code
      mac80211: move ieee80211_enable_ht function to mlme.c
      cfg80211: introduce scan IE limit attribute
      mac80211: pass all probe request IEs to driver
      mac80211: include HT capabilities in probe request
      cfg80211: add cipher capabilities
      mac80211: re-upload keys only after telling driver about associat=
ion
      mac80211: update injection documentation
      cfg80211: convert mutex assert to macro
      mac80211: add hardware restart function
      mac80211: improve powersave implementation
      mac80211: disable powersave if pm_qos asks for low latency
      mac80211: implement beacon filtering in software
      mac80211: enable PS by default
      mac80211: document powersaving/beacon filter future
      nl80211: send wiphy along with netdev
      cfg80211/mac80211: move wext SIWMLME into cfg80211
      cfg80211/nl80211: add IBSS API
      mac80211: convert to cfg80211 IBSS API
      cfg80211: clean up includes
      rndis_wlan: remove nickname support
      ar9170: support HT receive and channel config
      cfg80211: clear WEXT SSID when clearing IBSS
      cfg80211: mark all WEXT handlers _GPL
      mac80211: validate TIM IE length (redux)
      iwlwifi: rename PROBE_OPTION_MAX_API1 to PROBE_OPTION_MAX_3945
      iwlwifi: improve scan support
      iwlwifi: support truly passive scanning
      mac80211: fix IBSS code to not sleep while atomic
      rndis_wlan: make some symbols static
      mac80211: fix variable truncation on 32-bit
      mac80211: remove IEEE80211_CONF_CHANGE_DYNPS_TIMEOUT
      nl80211: allow configuring IBSS beacon interval
      mac80211: calculate maximum sleep interval

John W. Linville (6):
      rndis_wlan: initiate cfg80211 conversion
      rndis_wlan: convert get/set mode to cfg80211
      libertas: fix warning about %zd:
      rndis_wlan: select CFG80211 in Kconfig
      libertas: fix format warning
      wireless: remove some (bogus?) 'may be used uninitialized' warnin=
gs

Jouni Malinen (7):
      nl80211: Require auth type for NL80211_CMD_AUTHENTICATE
      nl80211: Generate deauth/disassoc event for locally generated fra=
mes
      nl80211: Add Michael MIC failure event
      mac80211: Report rejected association to user space SME
      mac80211: Allow scan to be requested in AP mode
      nl80211: Add set/get for frag/rts threshold and retry limits
      nl80211: Add event for authentication/association timeout

Jussi Kivilinna (6):
      cfg80211: add cfg80211_inform_bss
      rndis_wlan: change quality level scale
      rndis_wlan: convert get range to cfg80211
      rndis_wlan: convert scan to cfg80211
      rndis_wlan: fix initialization order for workqueue&workers
      rndis_wlan: free priv correctly when rndis_wext_bind fails

Larry Finger (5):
      b43legacy: Do not select HW_RANDOM
      rfkill: Fix broken rfkill LED in 2.6.30-rc1
      b43legacy: Fixes for beaconing
      b43legacy: Clean up beacon IRQ
      rtl8187: Implement TX/RX blink for LED

Luis R. Rodriguez (8):
      ath9k: Update maintainers for ath9k
      atheros: put atheros wireless drivers into ath/
      ath: space cleanup
      ath5k: sparse fix ath5k_led_on needs to be static
      cfg80211: respect API on orig_flags on channel for beacon hint
      cfg80211: add netlink channel put helper
      cfg80211: send regulatory beacon hint events to userspace
      atheros: fix propagation of bad EEPROM on regulatory init

Marek Vasut (1):
      Add support for CF8381 WiFi card.

Masakazu Mokuno (1):
      net/ps3: Update maintainer

Max Filippov (5):
      p54spi: mask value read from SPI_ADRS_DMA_WRITE_CTRL in p54spi_wa=
it_bit
      p54spi: fix p54spi_upload_firmware
      p54spi: fix p54spi_tx_frame DMA transfer initiation and skb clean=
up
      p54spi: compensate firmware alignment bug in p54spi_rx
      p54spi: get rid of busy-wait loops

Michael Buesch (2):
      b43: Do not "select" HW_RANDOM
      b43: Remove unnecessary MMIO in interrupt hotpath

Mohamed Abbas (4):
      iwlagn: Sync rxon active with changes
      iwlcore: fix channel display in debugfs
      iwlcore: Fix stay in table function.
      iwlwifi: allow config if device not ready

Pavel Roskin (1):
      ath5k: fix scanning in AR2424

Reinette Chatre (1):
      iwlwifi: change check triggering device restart after rfkill chan=
ge

Steven Luo (1):
      ath9k: reset after PCI FATAL/PERR interrupts

Sujith (28):
      ath9k: Remove a few unused flags
      ath9k: Remove redundant chainmask check
      ath9k: Cleanup debug messages
      ath9k: Change return value of ath9k_hw_fill_cap_info
      ath9k: Remove redundant variable for Interrupt Mitigation
      ath9k: Avoid unneeded casts
      ath9k: Cleanup buffer status handling
      ath9k: Remove a couple of unused variables in descriptor handling
      ath9k: Remove unused structures
      ath9k: Check for root debugfs file
      ath9k: Remove TIM from the interrupt mask
      ath9k: Remove the useless do..while loops
      ath9k: Initialize values when setting up the queue parameters
      ath9k: Trivial fix to handle AMPDU params properly
      ath9k: Clean Interrupt handling routine
      ath9k: Determine number of streams from HT capabilities
      ath9k: Fix bug in determining HT40 mode
      ath9k: Handle ASPM properly for RFKILL
      ath9k: Fix memleak on TX DMA failure
      ath9k: Fix bug in scan termination
      ath9k: Remove unused channel flags
      ath9k: Fix bug in checking HT flag
      ath9k: Fix bug in determining calibration support
      ath9k: Initialize ANI timers
      ath9k: Cleanup calibration interface
      ath9k: Use a consistent naming convention
      ath9k: Fix bug in calibration initialization
      ath9k: Remove CHANNEL_CW_INT handling in ath9k_hw_calibrate

Vasanthakumar Thiagarajan (1):
      mac80211: Don't access managed mode bits in non-managed mode

Vivek Natarajan (2):
      ath9k: No need to abort Rx path when autosleep is enabled.
      ath9k: Disable autosleep feature for AR9285 based chipsets.

Wey-Yi Guy (7):
      iwlwifi: merge and better support of suspend/resume for iwlagn an=
d iwl3945
      iwlwifi: adding triple stream rate support for MIMO3
      iwlwifi: adding MIMO3 support in rate scaling
      iwlwifi: add debug messages when start aggregation queue
      iwlwifi: Display decoded rate/mcs information
      iwlwifi: adding interrupt counter in debugfs for debugging
      iwlwifi: clean up unused NL80211_IFTYPE_MONITOR for Monitor mode

 Documentation/networking/mac80211-injection.txt   |   28 +-
 Documentation/rfkill.txt                          |   16 +-
 MAINTAINERS                                       |   10 +-
 arch/arm/mach-pxa/tosa-bt.c                       |    4 +-
 drivers/net/usb/hso.c                             |    4 +-
 drivers/net/wireless/Kconfig                      |   16 +-
 drivers/net/wireless/Makefile                     |    4 +-
 drivers/net/wireless/at76c50x-usb.c               |    1 +
 drivers/net/wireless/ath/Kconfig                  |    8 +
 drivers/net/wireless/ath/Makefile                 |    6 +
 drivers/net/wireless/{ =3D> ath}/ar9170/Kconfig     |    1 +
 drivers/net/wireless/{ =3D> ath}/ar9170/Makefile    |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/ar9170.h    |   32 +-
 drivers/net/wireless/{ =3D> ath}/ar9170/cmd.c       |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/cmd.h       |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/eeprom.h    |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/hw.h        |   15 +-
 drivers/net/wireless/{ =3D> ath}/ar9170/led.c       |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/mac.c       |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/main.c      |  613 ++++++++++-=
--
 drivers/net/wireless/{ =3D> ath}/ar9170/phy.c       |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/usb.c       |    0
 drivers/net/wireless/{ =3D> ath}/ar9170/usb.h       |    2 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/Kconfig      |    1 +
 drivers/net/wireless/{ =3D> ath}/ath5k/Makefile     |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/ath5k.h      |    5 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/attach.c     |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/base.c       |   74 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/base.h       |    1 -
 drivers/net/wireless/{ =3D> ath}/ath5k/caps.c       |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/debug.c      |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/debug.h      |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/desc.c       |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/desc.h       |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/dma.c        |    2 -
 drivers/net/wireless/{ =3D> ath}/ath5k/eeprom.c     |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/eeprom.h     |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/gpio.c       |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/initvals.c   |    8 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/led.c        |    4 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/pcu.c        |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/phy.c        |   49 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/qcu.c        |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/reg.h        |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/reset.c      |    2 +-
 drivers/net/wireless/{ =3D> ath}/ath5k/rfbuffer.h   |    0
 drivers/net/wireless/{ =3D> ath}/ath5k/rfgain.h     |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/Kconfig      |    1 +
 drivers/net/wireless/{ =3D> ath}/ath9k/Makefile     |    1 -
 drivers/net/wireless/{ =3D> ath}/ath9k/ahb.c        |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/ani.c        |    8 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/ani.h        |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/ath9k.h      |   65 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/beacon.c     |   17 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/calib.c      |  123 +--
 drivers/net/wireless/{ =3D> ath}/ath9k/calib.h      |   33 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/debug.c      |    3 +
 drivers/net/wireless/{ =3D> ath}/ath9k/debug.h      |   24 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/eeprom.c     |   24 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/eeprom.h     |    2 +
 drivers/net/wireless/{ =3D> ath}/ath9k/hw.c         |  179 ++---
 drivers/net/wireless/{ =3D> ath}/ath9k/hw.h         |   90 +--
 drivers/net/wireless/{ =3D> ath}/ath9k/initvals.h   |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/mac.c        |   63 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/mac.h        |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/main.c       |  374 ++++----
 drivers/net/wireless/{ =3D> ath}/ath9k/pci.c        |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/phy.c        |    4 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/phy.h        |    3 -
 drivers/net/wireless/{ =3D> ath}/ath9k/rc.c         |   26 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/rc.h         |    4 -
 drivers/net/wireless/{ =3D> ath}/ath9k/recv.c       |   85 +-
 drivers/net/wireless/{ =3D> ath}/ath9k/reg.h        |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/virtual.c    |    0
 drivers/net/wireless/{ =3D> ath}/ath9k/xmit.c       |   64 +-
 drivers/net/wireless/ath/main.c                   |   22 +
 drivers/net/wireless/{ath9k =3D> ath}/regd.c        |  241 +++---
 drivers/net/wireless/{ath9k =3D> ath}/regd.h        |   40 +-
 drivers/net/wireless/{ath9k =3D> ath}/regd_common.h |    0
 drivers/net/wireless/b43/Kconfig                  |    8 +-
 drivers/net/wireless/b43/b43.h                    |    8 +-
 drivers/net/wireless/b43/main.c                   |   69 +-
 drivers/net/wireless/b43/rfkill.c                 |    1 -
 drivers/net/wireless/b43legacy/Kconfig            |    8 +-
 drivers/net/wireless/b43legacy/b43legacy.h        |    8 +-
 drivers/net/wireless/b43legacy/main.c             |  193 +++-
 drivers/net/wireless/b43legacy/rfkill.c           |    1 -
 drivers/net/wireless/b43legacy/xmit.c             |    2 +-
 drivers/net/wireless/b43legacy/xmit.h             |    4 +-
 drivers/net/wireless/hostap/hostap_plx.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c           |  206 +++++
 drivers/net/wireless/iwlwifi/iwl-3945.h           |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c           |   13 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c           |   17 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c           |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c         |  410 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h         |   25 +
 drivers/net/wireless/iwlwifi/iwl-agn.c            |  791 ++-----------=
----
 drivers/net/wireless/iwlwifi/iwl-commands.h       |    7 +-
 drivers/net/wireless/iwlwifi/iwl-core.c           |  751 +++++++++++++=
++-
 drivers/net/wireless/iwlwifi/iwl-core.h           |   59 ++-
 drivers/net/wireless/iwlwifi/iwl-debug.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c        |   96 ++-
 drivers/net/wireless/iwlwifi/iwl-dev.h            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c         |    1 -
 drivers/net/wireless/iwlwifi/iwl-rx.c             |    7 -
 drivers/net/wireless/iwlwifi/iwl-scan.c           |  196 +---
 drivers/net/wireless/iwlwifi/iwl-sta.c            |   25 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c             |   12 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c       | 1017 +++----------=
--------
 drivers/net/wireless/libertas/cmd.c               |   26 +-
 drivers/net/wireless/libertas/defs.h              |   21 +
 drivers/net/wireless/libertas/dev.h               |    1 +
 drivers/net/wireless/libertas/host.h              |    3 +-
 drivers/net/wireless/libertas/hostcmd.h           |   28 +-
 drivers/net/wireless/libertas/if_cs.c             |   34 +-
 drivers/net/wireless/libertas/if_sdio.c           |   17 +-
 drivers/net/wireless/libertas/if_sdio.h           |    2 +
 drivers/net/wireless/libertas/if_spi.c            |    6 +-
 drivers/net/wireless/libertas/main.c              |   44 +-
 drivers/net/wireless/libertas/rx.c                |   48 +-
 drivers/net/wireless/libertas/tx.c                |    8 +-
 drivers/net/wireless/libertas/types.h             |    2 +
 drivers/net/wireless/p54/p54.h                    |   78 +-
 drivers/net/wireless/p54/p54common.c              |  216 +++--
 drivers/net/wireless/p54/p54spi.c                 |  127 ++--
 drivers/net/wireless/rndis_wlan.c                 |  666 ++++++-------=
-
 drivers/net/wireless/rt2x00/rt2400pci.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h              |   18 +
 drivers/net/wireless/rt2x00/rt2x00link.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c           |   16 +-
 drivers/net/wireless/rt2x00/rt61pci.c             |    7 +-
 drivers/net/wireless/rt2x00/rt61pci.h             |    6 -
 drivers/net/wireless/rtl818x/Makefile             |    2 +-
 drivers/net/wireless/rtl818x/rtl8187.h            |    7 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c        |   21 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c       |  218 +++++
 drivers/net/wireless/rtl818x/rtl8187_leds.h       |   57 ++
 drivers/platform/x86/acer-wmi.c                   |    1 -
 drivers/platform/x86/hp-wmi.c                     |    3 -
 drivers/platform/x86/sony-laptop.c                |    4 -
 drivers/platform/x86/toshiba_acpi.c               |    1 -
 include/linux/ieee80211.h                         |   41 +-
 include/linux/mmc/sdio_ids.h                      |    2 +
 include/linux/nl80211.h                           |  127 +++-
 include/linux/pci_ids.h                           |    2 +
 include/linux/rfkill.h                            |   14 -
 include/net/cfg80211.h                            |  897 +++++++++++++=
++---
 include/net/mac80211.h                            |  117 ++-
 include/net/regulatory.h                          |  101 ++
 include/net/wireless.h                            |  472 ----------
 net/mac80211/Kconfig                              |   16 +
 net/mac80211/cfg.c                                |   59 +-
 net/mac80211/debugfs.c                            |    8 +-
 net/mac80211/event.c                              |   17 +-
 net/mac80211/ht.c                                 |   84 --
 net/mac80211/ibss.c                               |  347 ++++----
 net/mac80211/ieee80211_i.h                        |   85 +-
 net/mac80211/iface.c                              |   16 +-
 net/mac80211/main.c                               |  122 +++-
 net/mac80211/mlme.c                               |  445 +++++++---
 net/mac80211/pm.c                                 |  110 +---
 net/mac80211/rx.c                                 |    2 +-
 net/mac80211/scan.c                               |   28 +-
 net/mac80211/spectmgmt.c                          |    2 +-
 net/mac80211/sta_info.c                           |   71 +--
 net/mac80211/sta_info.h                           |    3 +-
 net/mac80211/tx.c                                 |   35 +-
 net/mac80211/util.c                               |  240 +++++-
 net/mac80211/wext.c                               |  270 +-----
 net/mac80211/wpa.c                                |    2 +-
 net/rfkill/rfkill-input.c                         |   69 --
 net/rfkill/rfkill.c                               |   54 +-
 net/wimax/op-rfkill.c                             |    9 +-
 net/wireless/Makefile                             |    2 +-
 net/wireless/core.c                               |   27 +-
 net/wireless/core.h                               |   15 +-
 net/wireless/ibss.c                               |  369 ++++++++
 net/wireless/mlme.c                               |   50 +-
 net/wireless/nl80211.c                            |  639 ++++++++++++-=
-
 net/wireless/nl80211.h                            |   32 +-
 net/wireless/reg.c                                |   35 +-
 net/wireless/scan.c                               |   53 +-
 net/wireless/util.c                               |    6 +-
 net/wireless/wext-compat.c                        |  236 +++++-
 187 files changed, 7859 insertions(+), 5538 deletions(-)
 create mode 100644 drivers/net/wireless/ath/Kconfig
 create mode 100644 drivers/net/wireless/ath/Makefile
 rename drivers/net/wireless/{ =3D> ath}/ar9170/Kconfig (96%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/Makefile (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/ar9170.h (90%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/cmd.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/cmd.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/eeprom.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/hw.h (97%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/led.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/mac.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/main.c (77%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/phy.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/usb.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ar9170/usb.h (98%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/Kconfig (98%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/Makefile (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/ath5k.h (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/attach.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/base.c (98%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/base.h (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/caps.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/debug.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/debug.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/desc.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/desc.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/dma.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/eeprom.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/eeprom.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/gpio.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/initvals.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/led.c (97%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/pcu.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/phy.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/qcu.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/reg.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/reset.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/rfbuffer.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath5k/rfgain.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/Kconfig (97%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/Makefile (96%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/ahb.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/ani.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/ani.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/ath9k.h (94%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/beacon.c (98%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/calib.c (90%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/calib.h (81%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/debug.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/debug.h (89%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/eeprom.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/eeprom.h (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/hw.c (96%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/hw.h (87%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/initvals.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/mac.c (93%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/mac.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/main.c (91%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/pci.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/phy.c (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/phy.h (99%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/rc.c (98%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/rc.h (98%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/recv.c (93%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/reg.h (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/virtual.c (100%)
 rename drivers/net/wireless/{ =3D> ath}/ath9k/xmit.c (98%)
 create mode 100644 drivers/net/wireless/ath/main.c
 rename drivers/net/wireless/{ath9k =3D> ath}/regd.c (65%)
 rename drivers/net/wireless/{ath9k =3D> ath}/regd.h (85%)
 rename drivers/net/wireless/{ath9k =3D> ath}/regd_common.h (100%)
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187_leds.c
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187_leds.h
 create mode 100644 include/net/regulatory.h
 delete mode 100644 include/net/wireless.h
 create mode 100644 net/wireless/ibss.c

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2009-04-24.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
