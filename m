From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-06-29
Date: Fri, 29 Jun 2012 13:28:37 -0400
Message-ID: <20120629172836.GB30528@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5vNYLRcllDrimb99"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59213 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab2F2Vn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 17:43:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 8732baafc3f19e69df683c3f0f36c13cec746fb9

Dave,

Here is another batch of updates intended for 3.6.  This includes a
number of pulls, including ones from the mac80211, iwlwifi, ath6kl, and
wl12xx trees.  I also pulled from the wireless tree to avoid potential
build conflicts.  There are a number of other patches applied directly,
including a number for the Broadcom drivers and the mwifiex driver.

The updates cover the usual variety of new hardware support and feature
enhancements.  It's all good work, but there aren't any big headliners.
This does resolve a net-next/wireless-next merge conflict reported
by Stephen.

Please let me know if there are problems!

John

---

The following changes since commit 7a9bc9b81a5bc6e44ebc80ef781332e4385083f2:

  ipv4: Elide fib_validate_source() completely when possible. (2012-06-29 0=
1:36:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 8732baafc3f19e69df683c3f0f36c13cec746fb9:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-06-29 12:42:14 -0400)

----------------------------------------------------------------

Amitkumar Karwar (6):
      mwifiex: wake up main thread to handle Tx traffic if scan is delayed/=
aborted
      mwifiex: enhance power save for USB and PCIe chipsets
      mwifiex: wakeup main thread to handle command queued
      mwifiex: use correct firmware command to get power limits
      mwifiex: do not advertise custom regulatory domain capability
      mwifiex: retrieve correct max_power information in reg_notifier handl=
er

Arend van Spriel (6):
      brcmfmac: introduce checkdied debugfs functionality
      brcm80211: add mailing list address for brcm80211 drivers
      brcmfmac: make inclusion of vmalloc.h explicit fixing linux-next build
      brcmsmac: fix NULL pointer crash in brcms_c_regd_init()
      brcmfmac: reduce allocations needed during nvram data download
      brcmfmac: fix sparse warning introduced with checkdied patch

Arik Nemtsov (16):
      mac80211: stop Rx during HW reconfig
      mac80211: set only VO as a U-APSD enabled AC
      wlcore: suppress error message on Rx BA session removal
      wlcore: allow setting sleep_auth before interface init
      wlcore: reconfigure sleep_auth when removing interfaces
      wl18xx: increase Rx descriptors for PG2
      wl18xx: set Tx align quirk for PG2
      wl18xx: explicitly remove the 5Ghz MIMO HT cap
      wl18xx: sane defaults for HT capabilities
      wl18xx: split siso40 HT cap between 2Ghz and 5Ghz
      wlcore: cancel suspend when recovery is pending
      wlcore: don't allow SDIO read/writes after failure
      wlcore: force recovery on resume if suspended without recovering
      wlcore: check Rx-filter functions in the suspend path
      wlcore: refactor threaded IRQ routine
      wlcore: prevent recovery in the middle of resume

Arkady Miasnikov (1):
      wlcore: access the firmware memory via debugfs

Avinash Patil (7):
      ieee80211: definitions for Microsoft Vendor OUI and WPA OUI type
      mwifiex: set channel via start_ap handler for AP interface
      mwifiex: set HT capability based on cfg80211_ap_settings
      mwifiex: separate uAP WPA/WPA2 parsing from other BSS parameters
      mwifiex: support for WEP in AP mode
      ieee80211: more OUI type definitions for WLAN_OUI_MICROSOFT
      mwifiex: parse WPA IE and support WPA/WPA2 mixed mode for uAP

Bala Shanmugam (2):
      ath6kl: Add support for setting tx rateset.
      ath9k: fix incorrect profile type manupulation

Chun-Yeow Yeoh (9):
      cfg80211: add missing kernel-doc for mesh configuration structure
      {nl,cfg,mac}80211: fix the coding style related to mesh parameters
      {nl,cfg,mac}80211: implement dot11MeshHWMProotInterval and dot11MeshH=
WMPactivePathToRootTimeout
      mac80211: implement the proactive PREQ generation
      mac80211: implement the proactive PREP generation
      mac80211: invoke the timer only with correct dot11MeshHWMPRootMode va=
lue
      {nl,cfg,mac}80211: implement dot11MeshHWMPconfirmationInterval
      mac80211: fix the assignment of mesh element TTL
      mac80211: fix and improve mesh RANN processing

Eliad Peller (2):
      wlcore: update basic rates on channel switch
      wlcore: declare interface combinations

Emmanuel Grumbach (8):
      iwlwifi: check that we have enough bits to track the TX queues
      iwlwifi: print the scratch of all the buffers stuck in a queue
      iwlwifi: comment context requirements of the op_mode
      iwlwifi: disable BH before the call to iwl_op_mode_nic_error
      iwlwifi: don't disable interrupt in iwl_abort_notification_waits
      iwlwifi: don't disable interrupt while starting tx
      iwlwifi: protect use_ict with irq_lock
      iwlwifi: disable early power Off reset for all NICs

Etay Luz (1):
      ath6kl: support changing dtim period on AP mode

Eyal Shapira (6):
      wlcore: avoid using NET_IP_ALIGN for RX alignment
      wlcore: send EAPOLs with basic rate policy
      mac80211: fix cleanup if driver suspend callback fails
      wlcore: fix broken TX due to wrong queuing of recovery
      wlcore: queue recovery in case of bus errors during cmd_remove_peer
      wlcore: print stack trace in every recovery

Felix Fietkau (13):
      cfg80211: fix regression in multi-vif AP start
      ath9k_hw: remove aniState->noiseFloor
      ath9k_hw: fix OFDM weak signal detection handling
      ath9k_hw: remove confusing logic inversion in an ANI variable
      ath9k_hw: clean up / fix ANI mode checks related to beacon RSSI
      ath9k_hw: remove the old ANI implementation
      ath9k_hw: clean up defines and variables from the ANI implementation =
split
      ath9k: remove MIB interrupt support
      ath9k_hw: fix setting lower noise immunity values
      ath9k_hw: clean up ANI OFDM trigger handling
      ath9k: fix ANI operation in AP mode
      ath9k: update AR934x initvals to latest version
      ath9k: de-duplicate initvals

Franky Lin (5):
      brcmfmac: add support for bus specific data command
      brcmfmac: restrict dongle txglom disable to old SDIO core
      brcmfmac: move glom alignment setting to SDIO bus layer
      brcmfmac: use firmware data buffer directly for nvram
      brcmfmac: add BCM4334 support

Grazvydas Ignotas (3):
      wl1251: remove unused filter_work
      wl1251: fix filtering support
      wl1251: send filters to firmware as they are set

Ido Yariv (11):
      wlcore: Fix sdio out-of-sync power state
      wlcore: Disable interrupts while recovering
      wlcore: Change read/write ops to return errors
      wlcore: Change raw io functions to return errors
      wlcore: Propagate errors from wlcore_raw_*_data functions
      wlcore: Propagate errors from wl1271_read
      wlcore: Propagate errors from wl1271_write
      wlcore: Propagate errors from wl1271_raw_read32
      wlcore: Propagate errors from wl1271_raw_write32
      wlcore: Propagate errors from wl1271_read_hwaddr
      wlcore: Force checking of io functions' return values

Igal Chernobelsky (1):
      wlcore: read FW logs from FW memory on watchdog recovery

Javier Cardona (2):
      mac80211: Remove unused variable
      mac80211: Rename stainfo variable for the more common sta

Jeongdo Son (1):
      rt2x00: Add support for BUFFALO WLI-UC-GNM2 to rt2800usb.

Joe Perches (1):
      ath6kl: Add missing newline terminations

Johannes Berg (26):
      mac80211: remove unneeded ieee80211_run_deferred_scan()
      mac80211: allow cancelling dependent ROCs
      nl80211: fix sched scan match attribute name
      cfg80211/nl80211: fix kernel-doc
      iwlwifi: delay ROC if doing internal reset scan
      iwlwifi: fix 11n_disable EEPROM refactoring regression
      iwlwifi: use minimal time for radio reset scan
      iwlwifi: remove sku field from hw_params
      cfg80211: make some functions static
      nl80211: refactor __cfg80211_rdev_from_info
      nl80211: fix netns separation
      nl80211: change __cfg80211_rdev_from_info
      nl80211: use __cfg80211_rdev_from_attrs for testmode
      mac80211: fix double-start of remain-on-channel
      iwlwifi: fix radio reset scan dwell vs. quiet time
      iwlwifi: increase scan timeout
      iwlwifi: limit mac_change_interface to BSS context
      mac80211: remove TKIP debug
      mac80211: two small verbose debug cleanups
      mac80211: pass sdata to some RX functions
      mac80211: clean up debugging
      mac80211: rename driver-trace file
      mac80211: trace debug messages
      mac80211_hwsim: fix smatch/sparse complaints
      mac80211: remove unused function
      mac80211: make ieee80211_check_concurrent_iface netdev-independent

John W. Linville (8):
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.sipsolutions.net/mac80211-next
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'for-john' of git://git.sipsolutions.net/mac80211-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (1):
      ath6kl: Use correct max-scan-SSIDs limit

Kalle Valo (1):
      Merge remote branch 'wireless-next/master' into ath6kl-next

Kiran Reddy (1):
      ath6kl: separate ht cap for each band

Larry Finger (4):
      rtlwifi: rtl8192se: Fix gcc 4.7.x warning
      rtlwifi: Change debug level for deletion of an entry in CAM
      rtlwifi: Fix IRQ disabled warning
      rtlwifi: rtl8192se: Fix double inclusion of header pci.h

Luciano Coelho (8):
      mac80211: initialize sta pointer to avoid false-positive warning
      mac80211: use the correct capability info in ieee80211_set_associated=
()
      wlcore: add a debugfs entry to allow changing the sleep mode by hand
      wl18xx: use %zu for size_t arguments in printk calls
      Merge branch 'wl12xx-next' into for-linville
      wl18xx: deprecate PG1 support
      wlcore: fix some failure cases in wlcore_probe()
      Merge branch 'wl12xx-next' into for-linville

Mohammed Shafi Shajakhan (2):
      ath9k_hw: make use of the wrapper to check for MCI init
      ath9k: Fix signedness in a MCI debug message

Naveen Gangadharan (1):
      ath6kl: Add wow multicast firmware capability support

Naveen Singh (2):
      ath6kl: Include match ssid list in scheduled scan
      ath6kl: use firmware version from FW IE

Paul Bolle (1):
      iwlegacy: print how long queue was actually stuck

Pontus Fuchs (1):
      mac80211: Disallow changing chan type on monitor when CHAN_MODE_FIXED

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: define some additional cores IDs

Raja Mani (2):
      ath6kl: Remove unneeded memset in roam related config func
      ath6kl: Fix typo in htc mbox debug print msg

Rajkumar Manoharan (8):
      mac80211: cleanup offchannel_ps_enable argument
      ath9k_hw: fix BT mute at hw init
      ath9k: fix mci_is_enabled utility
      ath9k_hw: update ar9462 dac_async_fifo initval
      ath9k_hw: fix LNA control on WLAN sleep
      ath9k: do not sampling on ani timer when chip is in sleep
      ath9k_hw: rename mrcCCKOff to fix smatch warning
      ath9k_hw: fix smatch warning in ar9003_hw_spur_mitigate_mrc_cck

Seth Forshee (9):
      brcm80211: smac: don't set up tx power limits during initialization
      brcm80211: smac: always set channel specified by mac80211
      brcm80211: smac: remove unused code for 40MHz channels
      brcm80211: smac: clean up channel.c
      brcm80211: smac: inform mac80211 of the X2 regulatory domain
      brcm80211: smac: enable/disable radio on regulatory updates
      brcm80211: smac: use mac80211 channel data for tx power limits
      brcm80211: smac: don't validate channels against internal regulatory =
data
      brcm80211: smac: use current regulatory domain when checking whether =
OFDM is allowed

Sujith Manoharan (5):
      ath9k: Fix lockdep splat
      ath9k_htc: Change default listen interval to 1
      ath9k_htc: Use atomic operations for op_flags
      ath9k_htc: Fix IDLE power save
      ath9k: Fix compilation breakage

Sven Eckelmann (1):
      ath9k: raise aggregation limit to 64k for HT IBSS

Thomas Pedersen (4):
      ath6kl: enable enhanced bmiss detection
      ath6kl: issue wmi disconnect after notifying cfg80211
      ath6kl: fix fw capability parsing
      nl80211: specify RSSI threshold in scheduled scan

Vasanthakumar Thiagarajan (3):
      ath6kl: Fix missing gpio pin 9 configuration
      ath6kl: Fix race in aggregation reorder logic
      ath6kl: Fix unstable downlink throughput

Victor Goldenshtein (1):
      mac80211: add command to get current rssi

Will Hawkins (3):
      mac80211: Track auth frame registrations on IBSS ifaces
      mac80211: send auth in IBSS only if userspace isn't handling it
      mac80211: Allow userspace to register for auth frames in IBSS

Woody Hung (1):
      rt2x00 : RT3290 chip support v4

Xose Vazquez Perez (1):
      wireless: rtl818x: rtl8180 add devices ids

Yair Shapira (2):
      wlcore/wl12xx: add support for HP and SKW FEM radio manufacturers
      wlcore: add print logs of radio_status in case of BIP calibration

Yoni Divinsky (2):
      mac80211: save wmm_acm per sdata
      wlcore: do not report noise level in get survey op

 MAINTAINERS                                        |    1 +
 drivers/bcma/scan.c                                |    6 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  208 ++-
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    2 +
 drivers/net/wireless/ath/ath6kl/core.h             |   38 +-
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |    2 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   28 +-
 drivers/net/wireless/ath/ath6kl/main.c             |   27 +-
 drivers/net/wireless/ath/ath6kl/target.h           |    1 +
 drivers/net/wireless/ath/ath6kl/txrx.c             |   48 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |  148 +-
 drivers/net/wireless/ath/ath6kl/wmi.h              |   58 +-
 drivers/net/wireless/ath/ath9k/ani.c               |  489 +------
 drivers/net/wireless/ath/ath9k/ani.h               |   32 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |  176 +--
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    4 -
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    1 +
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   21 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   44 +-
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |   53 +-
 .../net/wireless/ath/ath9k/ar9330_1p2_initvals.h   |  882 +----------
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |  755 ++++------
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    7 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   | 1528 ++++++++--------=
----
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |  772 +---------
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |    2 -
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   10 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |  122 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   78 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   13 +-
 drivers/net/wireless/ath/ath9k/link.c              |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   36 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   17 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    4 -
 drivers/net/wireless/ath/ath9k/xmit.c              |   12 +
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |    8 +
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   29 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  500 +++++--
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |   17 +
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  | 1226 ++++------------
 drivers/net/wireless/brcm80211/brcmsmac/channel.h  |    4 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    2 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   36 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    1 +
 drivers/net/wireless/iwlegacy/common.c             |    7 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/dev.h             |    2 -
 drivers/net/wireless/iwlwifi/dvm/devices.c         |   13 -
 drivers/net/wireless/iwlwifi/dvm/lib.c             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   55 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |   29 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |   47 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    3 +
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |    5 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   16 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   30 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   19 +-
 drivers/net/wireless/mac80211_hwsim.c              |   10 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   65 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    7 +-
 drivers/net/wireless/mwifiex/fw.h                  |   23 +
 drivers/net/wireless/mwifiex/ie.c                  |   55 +-
 drivers/net/wireless/mwifiex/init.c                |    1 +
 drivers/net/wireless/mwifiex/ioctl.h               |   10 +
 drivers/net/wireless/mwifiex/main.c                |    3 +-
 drivers/net/wireless/mwifiex/main.h                |    8 +-
 drivers/net/wireless/mwifiex/scan.c                |   25 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   23 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   27 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    3 -
 drivers/net/wireless/mwifiex/uap_cmd.c             |  303 ++--
 drivers/net/wireless/rt2x00/Kconfig                |    8 +
 drivers/net/wireless/rt2x00/rt2800.h               |  173 ++-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  350 ++++-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   82 +-
 drivers/net/wireless/rt2x00/rt2800pci.h            |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h               |    1 +
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    9 +
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |    2 +
 drivers/net/wireless/rtlwifi/cam.c                 |    5 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   17 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    1 -
 drivers/net/wireless/ti/wl1251/cmd.c               |    9 -
 drivers/net/wireless/ti/wl1251/main.c              |   67 +-
 drivers/net/wireless/ti/wl1251/wl1251.h            |    1 -
 drivers/net/wireless/ti/wl12xx/cmd.c               |   16 +-
 drivers/net/wireless/ti/wl12xx/main.c              |  350 +++--
 drivers/net/wireless/ti/wl18xx/acx.h               |   34 +-
 drivers/net/wireless/ti/wl18xx/io.c                |   39 +-
 drivers/net/wireless/ti/wl18xx/io.h                |    4 +-
 drivers/net/wireless/ti/wl18xx/main.c              |  365 +++--
 drivers/net/wireless/ti/wlcore/acx.c               |    8 +-
 drivers/net/wireless/ti/wlcore/acx.h               |    5 +
 drivers/net/wireless/ti/wlcore/boot.c              |   84 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   77 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |   21 +
 drivers/net/wireless/ti/wlcore/conf.h              |    8 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |  255 ++++
 drivers/net/wireless/ti/wlcore/event.c             |   15 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |   12 +-
 drivers/net/wireless/ti/wlcore/ini.h               |   22 +-
 drivers/net/wireless/ti/wlcore/init.c              |   43 +-
 drivers/net/wireless/ti/wlcore/io.c                |   55 +-
 drivers/net/wireless/ti/wlcore/io.h                |  144 +-
 drivers/net/wireless/ti/wlcore/main.c              |  348 +++--
 drivers/net/wireless/ti/wlcore/ps.c                |   16 +-
 drivers/net/wireless/ti/wlcore/rx.c                |   41 +-
 drivers/net/wireless/ti/wlcore/rx.h                |   10 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   50 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   14 +-
 drivers/net/wireless/ti/wlcore/testmode.c          |   14 +
 drivers/net/wireless/ti/wlcore/tx.c                |   86 +-
 drivers/net/wireless/ti/wlcore/tx.h                |    4 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   24 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    9 +-
 include/linux/bcma/bcma.h                          |    7 +
 include/linux/ieee80211.h                          |   52 +-
 include/linux/nl80211.h                            |  156 +-
 include/net/cfg80211.h                             |   94 +-
 include/net/mac80211.h                             |   29 +-
 net/mac80211/Kconfig                               |   56 +-
 net/mac80211/Makefile                              |    6 +-
 net/mac80211/agg-rx.c                              |   34 +-
 net/mac80211/agg-tx.c                              |   72 +-
 net/mac80211/cfg.c                                 |  105 +-
 net/mac80211/debug.h                               |  170 +++
 net/mac80211/debugfs_netdev.c                      |   48 +-
 net/mac80211/driver-ops.h                          |   17 +-
 net/mac80211/driver-trace.c                        |    9 -
 net/mac80211/ht.c                                  |   10 +-
 net/mac80211/ibss.c                                |   91 +-
 net/mac80211/ieee80211_i.h                         |   20 +-
 net/mac80211/iface.c                               |   23 +-
 net/mac80211/key.c                                 |    4 +-
 net/mac80211/main.c                                |   11 +-
 net/mac80211/mesh.c                                |   16 +-
 net/mac80211/mesh.h                                |    4 +-
 net/mac80211/mesh_hwmp.c                           |  166 ++-
 net/mac80211/mesh_pathtbl.c                        |   30 +-
 net/mac80211/mesh_plink.c                          |   61 +-
 net/mac80211/mesh_sync.c                           |   47 +-
 net/mac80211/mlme.c                                |  219 ++-
 net/mac80211/offchannel.c                          |   21 +-
 net/mac80211/pm.c                                  |   10 +
 net/mac80211/rx.c                                  |   77 +-
 net/mac80211/sta_info.c                            |   44 +-
 net/mac80211/status.c                              |   11 +-
 net/mac80211/tkip.c                                |   43 +-
 net/mac80211/trace.c                               |   75 +
 net/mac80211/{driver-trace.h =3D> trace.h}           |   67 +-
 net/mac80211/tx.c                                  |   49 +-
 net/mac80211/util.c                                |    3 +
 net/mac80211/wme.c                                 |   11 +-
 net/mac80211/wme.h                                 |    2 +-
 net/wireless/core.c                                |   63 -
 net/wireless/core.h                                |   26 -
 net/wireless/mesh.c                                |    6 +
 net/wireless/nl80211.c                             |  282 +++-
 167 files changed, 6540 insertions(+), 6970 deletions(-)
 create mode 100644 net/mac80211/debug.h
 delete mode 100644 net/mac80211/driver-trace.c
 create mode 100644 net/mac80211/trace.c
 rename net/mac80211/{driver-trace.h =3D> trace.h} (96%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--5vNYLRcllDrimb99
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP7eXEAAoJEJctW/TcYTgGZVkP/2SsSvVqptLKz/dNxhc/7BJ4
VoGiZdLWd8cKp03PEILHeSXAhR+K/BaAnlV1kA28VRVCaKtYVImOV6AU26PvH4jZ
0u6JOTczLNZMqswVLzhvTdEr2htBGo/Fbc9+nfLNPuxkEuaxkWGuaTOE+kt2Wmua
NPepMvoXoNkrJFIRlW4U16NxOEa5NB/WIgTsu8zqfdAdOYPfQGX2IEmdbfCaJMeM
tOtgus7DYljpm0Lit0iX7r2qycvuDA4I6E4o1rDE/WUztOENDJvmEgyGPKvWmptB
4MFf+tOOvulJSi1eWHg1Esvm0ElWv44DIID1bb8pH1RUjx7xLh93ocy47yHtPk2O
O4fQbmLJvktX0k9l7x9MxK6WovKit93LRb5FFIOTCS/uYbNrzkAMoZ4ziBvmO+LT
/5V9yhsSHK57Dq3U+HrMoH4t3rG1EiQ8hfoFBR1ddjN15MSqSxMdjxJLwW1bNaKZ
zuEFNWIGn9VeerXp3J32p+cqV6VWhIqbFDNglkhPvE80ZF0wzFeqlwMBq6Jhg1fY
4XFuYAOvWFoaX7KOHQIC3pfN7FCYUlRdSE3RCvnYXf0OM3lPUjanFrkqAlWsX9bp
9Z1Dj/D059no34LeHfIV5YHbjNFzZXtOMLmxoJlJrey09R48QpSfXcaAEZu0O9bo
kHSG6OUWz4nq2tc8Rz1R
=T6er
-----END PGP SIGNATURE-----

--5vNYLRcllDrimb99--
