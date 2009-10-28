From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-10-28
Date: Wed, 28 Oct 2009 17:10:32 -0400
Message-ID: <20091028211031.GF2856@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47997 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbZJ1VQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 17:16:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I let my patches pile-up!  Yikes!!

This request includes the usual ton of stuff for -next -- driver
updates, fixes for some earlier -next stuff, a few cfg80211 changes to
accomodate the libertas driver, etc.  Of note is the rt2800pci support
added to the rt2x00 family.

Pleaset let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit b37b62fea1d1bf68ca51818f8eb1035188efd030:
  Ben Hutchings (1):
        sfc: Rename 'xfp' file and functions to reflect reality

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (5):
      iwlwifi/iwl3945: unify rts_tx_cmd_flag
      iwl3945: rename tx to tx_cmd
      iwlwifi/iwl3945: remove data_retry_limit
      iwl3945: rearrange the code.
      iwl3945: disable all tx fifos

Amitkumar Karwar (1):
      libertas: Check return status of command functions

Ben M Cahill (8):
      iwl3945: update iwl3945_apm_init()
      iwlwifi: turn off device when not used.
      iwl3945: remove unnecessary call to apm_ops.reset()
      iwlagn, iwl3945: remove apm_reset() functions
      iwl3945: streamline iwl3945_rfkill_poll()
      iwl3945: move iwl_power_initialize()
      iwlwifi: consolidate apm_init() functions
      iwlwifi: make sure device is reset when unloading driver

Benoit PAPILLAULT (1):
      zd1211rw: Fix TX status reporting in order to have proper rate control

Bob Copeland (1):
      ath5k: use noise calibration from madwifi hal

Christian Lamparter (3):
      ar9170: atomic pending A-MPDU counter
      ar9170usb: atomic pending urbs counter
      ar9170: don't filter BlockACK frames

David Kilroy (1):
      orinoco: use cfg80211 ethtool ops

David-John Willis (1):
      wl1251: add support for PG11 chips.

Holger Schurig (22):
      cfg80211: no cookies in cfg80211_send_XXX()
      cfg80211: remove warning in deauth case
      libertas: make __lbs_cmd_async() non-static
      libertas: cleanup host.h and hostcmd.h
      libertas: harmonize cmd.h
      libertas: make lbs_get_channel() static
      libertas: remove unused lbs_cmd_802_11_inactivity_timeout()
      libertas: remove unused 11d code
      libertas: remove unused 11d.h as well, priv->countryinfo
      libertas: change IW_ESSID_MAX_SIZE -> IEEE80211_MAX_SSID_LEN
      libertas: move scan/assoc related stuff
      libertas: sort variables in struct lbs_private
      libertas: get current channel out of priv->curbssparams
      libertas: move association related commands into assoc.c
      libertas: move lbs_send_iwevcustom_event() to wext.c
      libertas: remove handling for CMD_802_11_LED_GPIO_CTRL
      libertas: remove handling for CMD_GET_TSF
      libertas: remove "struct cmd_ds_gen"
      libertas: move SIOCGIWAP calls to wext.c
      libertas: move mic failure event to wext.c
      libertas: sort and categorize entries in decl.h
      libertas: remove some references to IW_MODE_abc

Ivo van Doorn (2):
      rt2x00: Add rt2x00soc bus module
      rt2x00: Implement support for rt2800pci

Javier Cardona (1):
      mac80211: Learn about mesh portals from multicast traffic

Jay Sternberg (1):
      iwlwifi: add missing commands to syslog messages

John W. Linville (3):
      mac80211: replace netif_tx_{start,stop,wake}_all_queues
      b43: use ieee80211_rx_ni()
      wl1251: re-disable PG10 chips

Juuso Oikarinen (44):
      wl1271: Correction to TX block allocation calculation
      wl1271: Security sequence number handling for TX (for WPA)
      wl1271: Correct TKIP header space handling in TX path
      wl1271: Implement delayed entry into ELP
      wl1271: mask aid bits 14 and 15 in ps-poll template
      wl1271: Implementation for SPI busy word checking
      wl1271: Configure rate policies based on AP rates
      wl1271: Update join usage
      wl1271: Corrections to TX path
      wl1271: use workqueue provided by mac80211 instead of the default
      wl1271: Clear probe-request template after scan
      wl1271: Multicast filtering configuration
      wl1271: Use vmalloc to allocate memory for firmware
      wl1271: Add connection monitoring configuration
      wl1271: Enable beacon filtering with the stack
      wl1271: Configure beacon filtering on if PSM used
      wl1271: Mask unneeded events from firmware to conserve power
      wl1271: Update memory mapping for firmware revision 6.1.0.0.241
      wl1271: Remove RX workaround
      wl1271: Add top-register access functions
      wl1271: RefClk configuration
      wl1271: Update interrupt handling by removing an extra SPI read
      wl1271: Enable ELP
      wl1271: Enable smart reflex
      wl1271: Update TX path block calucation algo
      wl1271: Remove outdated SPI functions
      wl1271: Update boot time configuration for the new firmware
      wl1271: Workaround for reference clock setting on boot.
      wl1271: Add structure for firmware configuration values
      wl1271: Add config structure for RX path parameters
      wl1271: Add config structure for TX path parameters
      wl1271: Add config structure for connection management parameters
      wl1271: Add config structure for FW init parameters
      wl1271: Move default FW config struct away from stack
      wl1271: Fix IRQ enable handling on FW init failure
      wl1271: Implement beacon early termination support
      wl1271: Remove busy-word checking
      wl1271: Fix multicast list handling
      wl1271: Fix event handling mechanism
      wl1271: Support for IPv4 ARP filtering
      wl1271: Remove unnecessary rx_descriptor memory allocation
      wl1271: Correct memory handling for FW boot
      wl1271: Fix filter configuration
      wl1271: Set IEEE80211_FCTL_TODS in the null data template

Kalle Valo (3):
      wl1251: rename spi device to wl1251
      mac80211: add ieee80211_rx_ni()
      wl1251: use ieee80211_rx_ni()

Luciano Coelho (15):
      wl1271: remove unecessary qual parameter from rx status
      wl1271: added Juuso Oikarinen as module author
      wl1271: hack to disable filters
      wl1271: implement cmd_disconnect
      wl1271: workaround to send a disconnect before rejoining
      wl1271: add workaround to avoid distortion due to excessive tx power
      wl1271: enable HW_AVAILABLE interrupt to fix ELP
      wl1271: use acx_rx_config instead of join when updating filters
      wl1271: remove unnecessary joins and join only when the bssid changes
      wl1271: make sure PS is disabled in PLT
      wl1271: fix sparse warnings about undeclared functions
      wl1271: added missing packed modifier in some acx structs
      wl1271: fix endianess issues
      wl1271: added missing packed modifier in some cmd structs
      wl1271: use ieee80211_rx_ni()

Luis R. Rodriguez (2):
      ath9k_hw: run the carrier leakage calibration fix for ar9271 as well
      ath9k_hw: run ath9k_hw_9271_pa_cal() initial calibration

Marek Lindner (1):
      ath9k: adjust ahb callbacks to new struct layout to avoid compile errors

Matthieu CASTET (1):
      airo : allow supend with card without power management

Michael Buesch (4):
      b43/legacy: Fix usage of host_pci pointer
      ssb: Put host pointers into a union
      b43: Remove me as maintainer
      b43: Optimize PIO scratchbuffer usage

Reinette Chatre (5):
      iwlwifi: fix userspace setting of sleep_level_override
      iwlwifi: move iwl_setup_mac to iwlagn
      iwlwifi: move rate scaling structures to header file
      iwlagn: store station rate scale information in mac80211 station structure
      iwlwifi: remove duplicate defines

Rui Paulo (1):
      mesh: use set_bit() to set MESH_WORK_HOUSEKEEPING.

Samuel Ortiz (13):
      iwmc3200wifi: WPS support
      iwmc3200wifi: CT kill support
      iwmc3200wifi: Profile flags can be WPA1 or WPA2 not both
      iwmc3200wifi: Improve rx debug
      iwmc3200wifi: Update statistics notification structure
      iwmc3200wifi: Update fixed size config definitions
      iwmc3200wifi: Tx power setting
      iwmc3200wifi: SDIO disable race fix
      iwmc3200wifi: Check for cmd pointer before dereferencing it
      iwmc3200wifi: Do not handle wifi command if the interface is not ready
      iwmc3200wifi: Try shared auth when open WEP fails
      iwmc3200wifi: Support unexpected reboot barker
      iwmc3200wifi: Set wiphy firmware version

Sujith (1):
      ath9k: Fix TX hang poll routine

Teemu Paasikivi (5):
      wl1271: Added 5 GHz parameters for wl1273
      wl1271: Scan only enabled channels
      wl1271: Added support to scan on 5 GHz band
      wl1271: Added 5 GHz support to join and rx
      wl1271: Checking of rx descriptor status fixed

Vivek Natarajan (1):
      ath: Updates for regulatory and country codes.

Wey-Yi Guy (23):
      iwlwifi: remove duplicated/unused definition
      iwlwifi: additional items in sensitivity range table
      iwlwifi: dynamic allocate tx queue structure
      iwlwifi: showing accumulative ucode statistics counters
      iwlwifi: update channel switch command API
      iwlwifi: show current power save status reported by uCode
      iwlwifi: identify eeprom version for 6x50 series NIC
      iwlwifi: fix incorrect otp blocks number for 6x50 series
      iwlwifi: set auto clock gate disable bit for 6x00/6x50 series
      iwlwifi: no chain noise support for 6x50 series
      iwlwifi: rework for static power save
      iwlwifi: fix gain computation for 5000 series and up
      iwlwifi: separate led function from statistic notification
      iwlwifi: update bt co-exit configuration parameter
      iwlwifi: specify the valid tx/rx chain in device config structure
      iwlwifi: increase max tfd payload size
      iwlwifi: choose thermal throttle method based on device config
      iwlwifi: issue ct_kill host command based on device config
      iwlwifi: add channel switch support to 5000 series and up
      iwlwifi: remove unused parameters
      iwlwifi: remove duplicated define
      iwlwifi: update lowest API version support for 6x00 & 6x50 series
      iwlwifi: minor comments changes for wimax co-exist command

Zhu Yi (6):
      iwlwifi: use paged Rx
      iwmc3200wifi: add BGN sdio device id
      iwmc3200wifi: allow joining an existed IBSS network
      iwmc3200wifi: handle coexistence radio notification
      iwlwifi: fix use after free bug for paged rx
      iwlwifi: reuse page for notification packets

 MAINTAINERS                                  |    1 -
 drivers/net/wireless/airo.c                  |    3 +-
 drivers/net/wireless/ath/ar9170/ar9170.h     |    2 +-
 drivers/net/wireless/ath/ar9170/hw.h         |    4 +-
 drivers/net/wireless/ath/ar9170/main.c       |   11 +-
 drivers/net/wireless/ath/ar9170/usb.c        |   12 +-
 drivers/net/wireless/ath/ar9170/usb.h        |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h       |   13 +
 drivers/net/wireless/ath/ath5k/attach.c      |    2 +
 drivers/net/wireless/ath/ath5k/phy.c         |  185 +-
 drivers/net/wireless/ath/ath5k/reg.h         |   11 +-
 drivers/net/wireless/ath/ath5k/reset.c       |   17 +-
 drivers/net/wireless/ath/ath9k/ahb.c         |    6 +-
 drivers/net/wireless/ath/ath9k/calib.c       |   28 +-
 drivers/net/wireless/ath/ath9k/xmit.c        |    2 +
 drivers/net/wireless/ath/regd.h              |    8 +
 drivers/net/wireless/ath/regd_common.h       |   32 +-
 drivers/net/wireless/b43/b43.h               |   16 +-
 drivers/net/wireless/b43/main.c              |    4 +-
 drivers/net/wireless/b43/pio.c               |   79 +-
 drivers/net/wireless/b43/xmit.c              |    7 +-
 drivers/net/wireless/b43legacy/main.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c      |   17 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h   |   12 -
 drivers/net/wireless/iwlwifi/iwl-3945.c      |  237 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    8 -
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h   |    3 -
 drivers/net/wireless/iwlwifi/iwl-4965.c      |  172 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |  219 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c      |  172 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c    |  108 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h    |  101 +
 drivers/net/wireless/iwlwifi/iwl-agn.c       |  154 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h  |   79 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |  260 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h      |   24 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h       |   11 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |  676 ++++--
 drivers/net/wireless/iwlwifi/iwl-dev.h       |   82 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c    |    8 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h    |    5 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c      |   23 +-
 drivers/net/wireless/iwlwifi/iwl-power.c     |   83 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c        |  177 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c      |   20 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   62 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c        |   45 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |  266 ++-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c |   47 +-
 drivers/net/wireless/iwmc3200wifi/commands.c |   31 +-
 drivers/net/wireless/iwmc3200wifi/commands.h |   70 +-
 drivers/net/wireless/iwmc3200wifi/fw.c       |    9 +
 drivers/net/wireless/iwmc3200wifi/iwm.h      |    6 +
 drivers/net/wireless/iwmc3200wifi/lmac.h     |    8 +
 drivers/net/wireless/iwmc3200wifi/main.c     |   46 +
 drivers/net/wireless/iwmc3200wifi/netdev.c   |    1 +
 drivers/net/wireless/iwmc3200wifi/rx.c       |   84 +-
 drivers/net/wireless/iwmc3200wifi/sdio.c     |   10 +-
 drivers/net/wireless/iwmc3200wifi/umac.h     |    5 +
 drivers/net/wireless/libertas/11d.c          |  696 ------
 drivers/net/wireless/libertas/11d.h          |  105 -
 drivers/net/wireless/libertas/Makefile       |    1 -
 drivers/net/wireless/libertas/assoc.c        |  445 ++++-
 drivers/net/wireless/libertas/assoc.h        |  141 ++-
 drivers/net/wireless/libertas/cmd.c          |  482 +----
 drivers/net/wireless/libertas/cmd.h          |  127 +-
 drivers/net/wireless/libertas/cmdresp.c      |  104 +-
 drivers/net/wireless/libertas/debugfs.c      |   27 +-
 drivers/net/wireless/libertas/decl.h         |   62 +-
 drivers/net/wireless/libertas/defs.h         |    1 -
 drivers/net/wireless/libertas/dev.h          |  424 +---
 drivers/net/wireless/libertas/host.h         |  960 +++++++--
 drivers/net/wireless/libertas/hostcmd.h      |  800 -------
 drivers/net/wireless/libertas/main.c         |  202 +--
 drivers/net/wireless/libertas/persistcfg.c   |    8 +-
 drivers/net/wireless/libertas/rx.c           |    2 +-
 drivers/net/wireless/libertas/scan.c         |  250 ++-
 drivers/net/wireless/libertas/scan.h         |   30 +
 drivers/net/wireless/libertas/tx.c           |    2 +-
 drivers/net/wireless/libertas/types.h        |    4 +-
 drivers/net/wireless/libertas/wext.c         |  144 +-
 drivers/net/wireless/libertas/wext.h         |    8 +
 drivers/net/wireless/orinoco/hw.c            |   33 +-
 drivers/net/wireless/orinoco/hw.h            |    3 +-
 drivers/net/wireless/orinoco/main.c          |   33 +-
 drivers/net/wireless/orinoco/orinoco.h       |    1 -
 drivers/net/wireless/rt2x00/Kconfig          |   30 +
 drivers/net/wireless/rt2x00/Makefile         |    2 +
 drivers/net/wireless/rt2x00/rt2800pci.c      | 3323 ++++++++++++++++++++++++++
 drivers/net/wireless/rt2x00/rt2800pci.h      | 1960 +++++++++++++++
 drivers/net/wireless/rt2x00/rt2x00.h         |    7 +
 drivers/net/wireless/rt2x00/rt2x00soc.c      |  159 ++
 drivers/net/wireless/rt2x00/rt2x00soc.h      |   52 +
 drivers/net/wireless/wl12xx/wl1251_main.c    |    7 +-
 drivers/net/wireless/wl12xx/wl1251_rx.c      |    2 +-
 drivers/net/wireless/wl12xx/wl1251_spi.c     |    2 +-
 drivers/net/wireless/wl12xx/wl1271.h         |   92 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c     |  369 +++-
 drivers/net/wireless/wl12xx/wl1271_acx.h     |  586 ++---
 drivers/net/wireless/wl12xx/wl1271_boot.c    |  215 +-
 drivers/net/wireless/wl12xx/wl1271_boot.h    |   22 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c     |  329 ++-
 drivers/net/wireless/wl12xx/wl1271_cmd.h     |  115 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h    |  911 +++++++
 drivers/net/wireless/wl12xx/wl1271_event.c   |   64 +-
 drivers/net/wireless/wl12xx/wl1271_event.h   |   30 +-
 drivers/net/wireless/wl12xx/wl1271_init.c    |  155 +-
 drivers/net/wireless/wl12xx/wl1271_init.h    |   53 +-
 drivers/net/wireless/wl12xx/wl1271_main.c    |  963 ++++++--
 drivers/net/wireless/wl12xx/wl1271_ps.c      |   68 +-
 drivers/net/wireless/wl12xx/wl1271_ps.h      |    2 +-
 drivers/net/wireless/wl12xx/wl1271_reg.h     |   47 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c      |   86 +-
 drivers/net/wireless/wl12xx/wl1271_rx.h      |    4 +-
 drivers/net/wireless/wl12xx/wl1271_spi.c     |  311 ++--
 drivers/net/wireless/wl12xx/wl1271_spi.h     |   65 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c      |   76 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h      |   18 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h   |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c      |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.h      |   18 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |  202 ++-
 drivers/net/wireless/zd1211rw/zd_mac.h       |   25 +-
 drivers/net/wireless/zd1211rw/zd_usb.c       |    4 +-
 drivers/ssb/driver_pcicore.c                 |    4 +-
 include/linux/ssb/ssb.h                      |   20 +-
 include/net/cfg80211.h                       |   31 +-
 include/net/mac80211.h                       |   32 +-
 net/mac80211/iface.c                         |    4 +-
 net/mac80211/mesh.c                          |    4 +-
 net/mac80211/mlme.c                          |   22 +-
 net/mac80211/rx.c                            |   21 +-
 net/mac80211/scan.c                          |   10 +-
 net/wireless/mlme.c                          |   45 +-
 137 files changed, 13469 insertions(+), 6003 deletions(-)
 delete mode 100644 drivers/net/wireless/libertas/11d.c
 delete mode 100644 drivers/net/wireless/libertas/11d.h
 delete mode 100644 drivers/net/wireless/libertas/hostcmd.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800pci.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800pci.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00soc.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00soc.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_conf.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2009-10-28.patch.bz2

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
