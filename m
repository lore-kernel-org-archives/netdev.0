From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2011-08-22
Date: Mon, 22 Aug 2011 15:58:57 -0400
Message-ID: <20110822195857.GL2534@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

This is a batch of updates intended for 3.2.

Highlights include a wireless extensions dependency cleanup amongst
a number of drivers, and the inclusion of the ath6kl driver
in drivers/net/wireless (along with its removal from staging).
Also included are a number of updates to mac80211, bcma, mwifiex,
libertas, ath9k, iwlagn, and a number of other drivers.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ca1ba7caa68520864e4b9227e67f3bbc6fed=
373b:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/=
jkirsher/net-next (2011-08-20 17:25:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.=
git for-davem

Alex Hacker (1):
      ath9k_hw: use register name in place of magic value

Amitkumar Karwar (2):
      mwifiex: print driver version information
      mwifiex: use cfg80211 dynamic scan table and cfg80211_get_bss API

Baruch Siach (1):
      mac80211/mesh: make the preq queue lock consistent

Bing Zhao (2):
      mwifiex: remove wireless.h inclusion and fix resulting bugs
      mwifiex: remove redundant variable scan_table_idx

Dan Carpenter (1):
      libertas: remove some dead code in if_spi_prog_helper_firmware()

Daniel Drake (5):
      libertas: link mesh device to wiphy
      libertas_usb: use USB interface as parent device
      libertas_usb: program OLPC EC wakeup mask for wake-on-WLAN
      libertas: disable functionality when interface is down
      libertas: implement if_sdio runtime power management

Eliad Peller (1):
      mac80211: clear sta.drv_priv on reconfiguration

=46elix Fietkau (7):
      ath9k_hw: remove the tx power index offset
      ath9k_hw: fix calculated runtime tx power limit
      ath9k_hw: do not limit initial tx power to 20 dbm
      ath9k_hw: calculate a much better approximation of channel noise
      ath9k: use the new channel noise value for signal strength and su=
rvey info
      cfg80211: fix a crash in nl80211_send_station
      ath9k: avoid sending a-mpdu packets to sleeping stations

Hauke Mehrtens (12):
      bcma: move parsing of EEPROM into own function.
      bcma: move initializing of struct bcma_bus to own function.
      bcma: add functions to scan cores needed on SoCs
      bcma: add SOC bus
      bcma: add mips driver
      bcma: add serial console support
      bcma: get CPU clock
      bcm47xx: prepare to support different buses
      bcm47xx: make it possible to build bcm47xx without ssb.
      bcm47xx: add support for bcma bus
      bcm47xx: fix irq assignment for new SoCs.
      b43: add core rev 17 used on bcma SoC.

Helmut Schaa (5):
      mac80211: Stop TX BA session if buf_size is zero
      mac80211: Don't use a buf_size=3D0 in ADDBA requests
      mac80211: Fill in skb->protocol information for injected frames
      mac80211: Don't use EAPOL frames for rate sampling
      rt2x00: Fix PCI interrupt processing race on SMP systems

Javier Cardona (1):
      mac80211: fix erroneous clearing of MESH_PATH_SN_VALID flag

Joe Perches (1):
      cfg80211: Update REG_DBG_PRINT macro and uses

Johannes Berg (18):
      cfg80211: split wext compatibility to separate header
      iwlagn: remove wireless extensions inclusions
      iwlegacy: remove wireless extensions inclusions
      ath5k: remove wireless extensions inclusions
      b43: remove wireless extensions inclusions
      b43legacy: remove wireless extensions inclusions
      rndis_wlan: remove wireless extensions inclusions
      wl12xx: remove wext dependencies
      wl1251: remove wext dependencies
      mwifiex: add wext include
      mac80211: remove linux/wireless.h inclusion
      cfg80211: remove unused wext handler exports
      iwlagn: reserve queue 10 for TX during scan dwell
      iwlagn: separate firmware version warning
      iwlagn: bump firmware API for some devices
      iwlagn: move context init after firmware loading
      iwlagn: support new P2P implementation
      mac80211: remove offchannel_tx API

John W. Linville (3):
      Merge branch 'ath6kl-next' of master.kernel.org:/.../kvalo/ath6kl
      Merge branch 'for-linville' of git://git.kernel.org/.../kvalo/ath=
6kl
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next into for-davem

Jouni Malinen (7):
      mac80211_hwsim: Fix RX status reporting for HT
      nl80211: Indicate driver-based offchannel TX on mgmt_tx_cancel_wa=
it
      cfg80211/nl80211: Send AssocReq IEs to user space in AP mode
      nl80211/cfg80211: Make addition of new sinfo fields safer
      nl80211/cfg80211: Allow SSID to be specified in new beacon comman=
d
      nl80211/cfg80211: Add crypto settings into NEW_BEACON
      nl80211/cfg80211: Add extra IE configuration to AP mode setup

Kalle Valo (8):
      Add ath6kl cleaned up driver
      ath6kl: don't force foreground scan when connected
      ath6kl: fix atomicity in ath6kl_cfg80211_scan_node()
      ath6kl: fix crash when interface is closed but scan is ongoing
      ath6kl: remove dependency to wireless extensions
      ath6kl: change aggreation timeout message from an error to a debu=
g message
      ath6kl: fix function name conflicts with ath9k
      staging: remove ath6kl

Larry Finger (3):
      rtlwifi: Eliminate raw reads and writes from PCIe portion
      rtlwifi: Remove raw read/write routines from header
      b43: Remove EXPERIMENTAL designation from LP PHY selection

Marek Lindner (1):
      ath9k: remove eeprom txgain override for minor version < 19

Mohammed Shafi Shajakhan (3):
      ath9k_htc: minor clean-up
      ath9k: optimize rate control statistics
      ath9k: remove obselete comments

Pavel Roskin (13):
      ath9k: remove all references to subsysid, it's never used
      ath5k: remove unused and write-only structures and fields
      ath5k: remove most references to XR
      ath5k: eliminate CHANNEL_* macros, use AR5K_MODE_* in channel->hw=
_value
      b43legacy: remove 64-bit DMA support
      b43legacy: report core number
      pcmcia: add PCMCIA_DEVICE_MANF_CARD_PROD_ID3
      hostap_cs: support cards with "Version 01.02" as third product ID
      orinoco_cs: be more careful when matching cards with ID 0x0156:0x=
0002
      ath: fix spelling of Grenada
      ath5k: clean up base.h and its use
      ath5k: remove last references to "softc"
      lib80211: remove exports for functions not called by other module=
s

Rafa=C5=82 Mi=C5=82ecki (2):
      ssb: define boardflags
      bcma: use boardflags define from ssb code

Raja Mani (6):
      ath6kl: Print bad trailer data only when htc fails to parse trail=
er info
      ath6kl: Rearrange the variable and the value position in IF condi=
tion
      ath6kl: Avoid two memset to clear src and desr mac addr variable =
memory in ath6kl_wmi_dot11_hdr_remove()
      ath6kl: Use bit field macros to maintain wlan enabled and disable=
d status
      ath6kl: Fix crash during the connection process
      ath6kl: Release the memory allocated for the firmware

Rajkumar Manoharan (13):
      ath9k_hw: Add dump_eeprom support for AR9003
      ath9k_hw: Add dump_eeprom support for eeprom_4k
      ath9k_hw: Add dump_eeprom support for AR9287
      ath9k_hw: Add dump_eeprom support for eeprom_def
      ath9k: Dump base eeprom header
      ath9k: Dump modal eeprom header
      ath9k: Remove virtual wiphy specific frame type
      ath9k_hw: Optimize rx descriptor processing for AR9003
      ath9k_hw: Update the radio parameters related to high_power
      ath9k_hw: Update AR9003 high_power tx gain table
      ath9k: do not enable interrupt on set interrupt mask
      ath9k_hw: Fix incorrect spur_freq_sd for AR9003
      ath9k: Use atomic reference count for interrupt ops

Sergei Shtylyov (1):
      ath9k: use pci_dev->subsystem_device

Vasanthakumar Thiagarajan (33):
      ath6kl: cleanup callbacks for different scatter gather method
      ath6kl: Move ath6kl_sdio_async_rw_scatter() down to other hif_ops=
 functions
      ath6kl: Remove struct hif_scatter_req_priv
      ath6kl: Remove useless flags in hif_scatter_req
      ath6kl: Remove endpoint reference from hif_scatter_req
      ath6kl: Refactor refactor ath6kl_sdio_setup_scat_resource()
      ath6kl: Cleanup ath6kl_sdio_enable_scatter()
      ath6kl: Cleanup ath6kl_sdio_cleanup_scatter()
      ath6kl: Move down scatter enable and cleanup functions
      ath6kl: Merge scatter gather setup functions for two method
      ath6kl: Moe virt_scat from hif_dev_scat_sup_info to hif_scatter_r=
eq
      ath6kl: Refactor ath6kl_sdio_read_write_sync()
      ath6kl: Merge scatter rw request functions into one
      ath6kl: Remove ath6kldev_setup_msg_bndl()
      ath6kl: Minor cleanup in ath6kldev_submit_scat_req()
      ath6kl: Remove callback msg_pending() and used the function direc=
tly
      ath6kl: Move bundle size from ath6kl_device to htc_target
      ath6kl: Move block_sz and block_mask from ath6kl_device to htc_ta=
rget
      ath6kl: Move scatter information from ath6kl_device to htc_target
      ath6kl: Bypass reading irq status based on chk_irq_status_cnt
      ath6kl: Move chk_irq_status_cnt from ath6kl_device to htc_target
      ath6kl: Remove unused struct ath6kl_async_reg_io_buffer
      ath6kl: Cleanup void *parent_dev in struct wmi
      ath6kl: Move scan table from wmi to ath6kl
      ath6kl: Cleanup parameters for wlan_refresh_inactive_nodes()
      ath6kl: Remove bssid from struct wmi
      ath6kl: Remove ath6kl_wmi_get_current_bssid()
      ath6kl: Cleanup parameters of wlan_node_table_init()
      ath6kl: Move initialization/deinitialization of scan_table to app=
ropriate functions
      ath6kl: Pass only the needed scan_table to ath6kl_wmi_iterate_nod=
es()
      ath6kl: Remove ath6kl_wmi_iterate_nodes()
      ath6kl: Use ath6kl_cfg80211_scan_node() directly instead of funct=
ion pointer
      ath6kl: Cleanup void * in ath6kl_cfg80211_scan_node()

Wey-Yi Guy (4):
      iwlagn: default smps mode for 1000 series device
      iwlagn: Remove ht40 support from 5.2GHz for _bgn devices
      iwlagn: change default sensitivity value for 5000 and 6000 series
      iwlagn: support v2 of enhanced sensitivity table

Yogesh Ashok Powar (1):
      cfg80211/mac80211: move information element parsing logic to cfg8=
0211

 arch/mips/Kconfig                                  |    8 +-
 arch/mips/bcm47xx/Kconfig                          |   31 +
 arch/mips/bcm47xx/Makefile                         |    3 +-
 arch/mips/bcm47xx/gpio.c                           |   82 +-
 arch/mips/bcm47xx/irq.c                            |   12 +
 arch/mips/bcm47xx/nvram.c                          |   29 +-
 arch/mips/bcm47xx/serial.c                         |   46 +-
 arch/mips/bcm47xx/setup.c                          |   90 +-
 arch/mips/bcm47xx/time.c                           |   16 +-
 arch/mips/bcm47xx/wgt634u.c                        |   14 +-
 arch/mips/include/asm/mach-bcm47xx/bcm47xx.h       |   26 +-
 arch/mips/include/asm/mach-bcm47xx/gpio.h          |  108 +-
 arch/mips/pci/pci-bcm47xx.c                        |    6 +
 drivers/bcma/Kconfig                               |   13 +
 drivers/bcma/Makefile                              |    2 +
 drivers/bcma/bcma_private.h                        |   16 +
 drivers/bcma/core.c                                |    2 +
 drivers/bcma/driver_chipcommon.c                   |   53 +
 drivers/bcma/driver_chipcommon_pmu.c               |  133 +
 drivers/bcma/driver_mips.c                         |  256 +
 drivers/bcma/driver_pci.c                          |   16 +-
 drivers/bcma/host_soc.c                            |  183 +
 drivers/bcma/main.c                                |   70 +-
 drivers/bcma/scan.c                                |  348 +-
 drivers/net/wireless/ath/Kconfig                   |    1 +
 drivers/net/wireless/ath/Makefile                  |    1 +
 drivers/net/wireless/ath/ath5k/ahb.c               |    4 +-
 drivers/net/wireless/ath/ath5k/ani.c               |    1 -
 drivers/net/wireless/ath/ath5k/ani.h               |    4 +
 drivers/net/wireless/ath/ath5k/ath5k.h             |   98 +-
 drivers/net/wireless/ath/ath5k/attach.c            |   18 +-
 drivers/net/wireless/ath/ath5k/base.c              |   31 +-
 drivers/net/wireless/ath/ath5k/base.h              |   55 +-
 drivers/net/wireless/ath/ath5k/caps.c              |    2 +-
 drivers/net/wireless/ath/ath5k/debug.c             |   15 +-
 drivers/net/wireless/ath/ath5k/desc.c              |    1 -
 drivers/net/wireless/ath/ath5k/dma.c               |    1 -
 drivers/net/wireless/ath/ath5k/eeprom.c            |   10 +-
 drivers/net/wireless/ath/ath5k/gpio.c              |    1 -
 drivers/net/wireless/ath/ath5k/initvals.c          |    1 -
 drivers/net/wireless/ath/ath5k/led.c               |    1 -
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    5 +-
 drivers/net/wireless/ath/ath5k/pci.c               |    4 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |    5 +-
 drivers/net/wireless/ath/ath5k/phy.c               |   91 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |   10 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   79 +-
 drivers/net/wireless/ath/ath5k/rfkill.c            |    2 +-
 drivers/net/wireless/ath/ath5k/sysfs.c             |    1 -
 drivers/net/wireless/ath/ath5k/trace.h             |    3 +-
 drivers/net/wireless/ath/ath6kl/Kconfig            |   15 +
 drivers/net/wireless/ath/ath6kl/Makefile           |   35 +
 drivers/net/wireless/ath/ath6kl/bmi.c              |  692 +++
 drivers/net/wireless/ath/ath6kl/bmi.h              |  250 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         | 1538 +++++
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |   39 +
 drivers/net/wireless/ath/ath6kl/common.h           |  180 +
 drivers/net/wireless/ath/ath6kl/core.h             |  544 ++
 drivers/net/wireless/ath/ath6kl/debug.c            |  150 +
 drivers/net/wireless/ath/ath6kl/debug.h            |  105 +
 drivers/net/wireless/ath/ath6kl/hif-ops.h          |   72 +
 drivers/net/wireless/ath/ath6kl/hif.h              |  207 +
 drivers/net/wireless/ath/ath6kl/htc.c              | 2457 ++++++++
 drivers/net/wireless/ath/ath6kl/htc.h              |  607 ++
 drivers/net/wireless/ath/ath6kl/htc_hif.c          |  641 ++
 drivers/net/wireless/ath/ath6kl/htc_hif.h          |   92 +
 drivers/net/wireless/ath/ath6kl/init.c             | 1303 ++++
 drivers/net/wireless/ath/ath6kl/main.c             | 1337 ++++
 drivers/net/wireless/ath/ath6kl/node.c             |  234 +
 drivers/net/wireless/ath/ath6kl/sdio.c             |  912 +++
 drivers/net/wireless/ath/ath6kl/target.h           |  331 +
 drivers/net/wireless/ath/ath6kl/txrx.c             | 1457 +++++
 drivers/net/wireless/ath/ath6kl/wmi.c              | 2743 +++++++++
 drivers/net/wireless/ath/ath6kl/wmi.h              | 2018 ++++++
 drivers/net/wireless/ath/ath9k/ahb.c               |    2 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  190 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  150 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   15 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    6 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   18 +-
 drivers/net/wireless/ath/ath9k/calib.c             |   15 +
 drivers/net/wireless/ath/ath9k/calib.h             |    1 +
 drivers/net/wireless/ath/ath9k/debug.c             |   60 +
 drivers/net/wireless/ath/ath9k/eeprom.h            |    2 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |  135 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  122 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  150 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    2 +
 drivers/net/wireless/ath/ath9k/htc.h               |    3 -
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    1 -
 drivers/net/wireless/ath/ath9k/hw.c                |   10 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    9 +-
 drivers/net/wireless/ath/ath9k/init.c              |    8 +-
 drivers/net/wireless/ath/ath9k/mac.c               |   16 +-
 drivers/net/wireless/ath/ath9k/main.c              |   10 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    4 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    4 +-
 drivers/net/wireless/ath/ath9k/rc.h                |    6 -
 drivers/net/wireless/ath/ath9k/recv.c              |   10 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   12 +-
 drivers/net/wireless/ath/regd.h                    |    2 +-
 drivers/net/wireless/ath/regd_common.h             |    2 +-
 drivers/net/wireless/b43/Kconfig                   |    6 +-
 drivers/net/wireless/b43/main.c                    |    2 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |    1 -
 drivers/net/wireless/b43legacy/dma.c               |  374 +-
 drivers/net/wireless/b43legacy/dma.h               |  107 -
 drivers/net/wireless/b43legacy/main.c              |    4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    1 +
 drivers/net/wireless/iwlegacy/iwl-3945-led.c       |    1 -
 drivers/net/wireless/iwlegacy/iwl-3945-rs.c        |    1 -
 drivers/net/wireless/iwlegacy/iwl-3945.c           |    1 -
 drivers/net/wireless/iwlegacy/iwl-4965-led.c       |    1 -
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c        |    1 -
 drivers/net/wireless/iwlegacy/iwl-4965.c           |    1 -
 drivers/net/wireless/iwlegacy/iwl-led.c            |    1 -
 drivers/net/wireless/iwlegacy/iwl3945-base.c       |    1 -
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |    1 -
 drivers/net/wireless/iwlwifi/Kconfig               |   17 -
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   16 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   24 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   13 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   20 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   69 +-
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   47 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   23 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   30 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  388 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   34 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    5 +
 drivers/net/wireless/iwlwifi/iwl-core.h            |    5 +
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   29 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    1 -
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   19 +-
 drivers/net/wireless/iwlwifi/iwl-trans.c           |   10 +-
 drivers/net/wireless/libertas/cfg.c                |   69 +-
 drivers/net/wireless/libertas/cfg.h                |    1 +
 drivers/net/wireless/libertas/cmd.c                |    6 +-
 drivers/net/wireless/libertas/decl.h               |    4 +
 drivers/net/wireless/libertas/dev.h                |   28 +-
 drivers/net/wireless/libertas/ethtool.c            |    1 +
 drivers/net/wireless/libertas/if_sdio.c            |  277 +-
 drivers/net/wireless/libertas/if_spi.c             |    4 -
 drivers/net/wireless/libertas/if_usb.c             |   13 +-
 drivers/net/wireless/libertas/main.c               |  180 +-
 drivers/net/wireless/libertas/mesh.c               |   77 +-
 drivers/net/wireless/libertas/mesh.h               |   27 +-
 drivers/net/wireless/libertas/rx.c                 |    1 +
 drivers/net/wireless/libertas/tx.c                 |    1 +
 drivers/net/wireless/mac80211_hwsim.c              |    6 +
 drivers/net/wireless/mwifiex/cfg80211.c            |  209 +-
 drivers/net/wireless/mwifiex/fw.h                  |   15 +-
 drivers/net/wireless/mwifiex/init.c                |   21 -
 drivers/net/wireless/mwifiex/ioctl.h               |    5 +-
 drivers/net/wireless/mwifiex/join.c                |   32 -
 drivers/net/wireless/mwifiex/main.c                |    4 +
 drivers/net/wireless/mwifiex/main.h                |   55 +-
 drivers/net/wireless/mwifiex/scan.c                | 1578 +----
 drivers/net/wireless/mwifiex/sta_event.c           |    9 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  230 +-
 drivers/net/wireless/orinoco/wext.c                |    1 +
 drivers/net/wireless/rndis_wlan.c                  |    2 -
 drivers/net/wireless/rt2x00/rt2400pci.c            |   39 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   39 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   46 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    1 -
 drivers/net/wireless/rt2x00/rt61pci.c              |   34 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   37 +-
 drivers/net/wireless/rtlwifi/pci.h                 |   26 -
 drivers/net/wireless/wl1251/cmd.h                  |    2 +-
 drivers/net/wireless/wl1251/wl12xx_80211.h         |    2 +-
 drivers/net/wireless/wl12xx/cmd.h                  |    4 +-
 drivers/net/wireless/wl12xx/main.c                 |    2 +-
 drivers/net/wireless/wl12xx/scan.h                 |    6 +-
 drivers/net/wireless/wl12xx/wl12xx.h               |    4 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h         |    2 +-
 drivers/staging/Kconfig                            |    2 -
 drivers/staging/Makefile                           |    1 -
 drivers/staging/ath6kl/Kconfig                     |  158 -
 drivers/staging/ath6kl/Makefile                    |  122 -
 drivers/staging/ath6kl/TODO                        |   25 -
 drivers/staging/ath6kl/bmi/include/bmi_internal.h  |   54 -
 drivers/staging/ath6kl/bmi/src/bmi.c               | 1010 ---
 .../staging/ath6kl/hif/common/hif_sdio_common.h    |   87 -
 .../hif/sdio/linux_sdio/include/hif_internal.h     |  131 -
 .../staging/ath6kl/hif/sdio/linux_sdio/src/hif.c   | 1273 ----
 .../ath6kl/hif/sdio/linux_sdio/src/hif_scatter.c   |  393 --
 drivers/staging/ath6kl/htc2/AR6000/ar6k.c          | 1479 -----
 drivers/staging/ath6kl/htc2/AR6000/ar6k.h          |  401 --
 drivers/staging/ath6kl/htc2/AR6000/ar6k_events.c   |  783 ---
 drivers/staging/ath6kl/htc2/AR6000/ar6k_gmbox.c    |  755 ---
 .../ath6kl/htc2/AR6000/ar6k_gmbox_hciuart.c        | 1284 ----
 drivers/staging/ath6kl/htc2/htc.c                  |  575 --
 drivers/staging/ath6kl/htc2/htc_debug.h            |   38 -
 drivers/staging/ath6kl/htc2/htc_internal.h         |  211 -
 drivers/staging/ath6kl/htc2/htc_recv.c             | 1572 -----
 drivers/staging/ath6kl/htc2/htc_send.c             | 1018 ---
 drivers/staging/ath6kl/htc2/htc_services.c         |  450 --
 drivers/staging/ath6kl/include/a_config.h          |   31 -
 drivers/staging/ath6kl/include/a_debug.h           |  195 -
 drivers/staging/ath6kl/include/a_drv.h             |   32 -
 drivers/staging/ath6kl/include/a_drv_api.h         |  204 -
 drivers/staging/ath6kl/include/a_osapi.h           |   32 -
 drivers/staging/ath6kl/include/aggr_recv_api.h     |  140 -
 drivers/staging/ath6kl/include/ar3kconfig.h        |   65 -
 drivers/staging/ath6kl/include/ar6000_api.h        |   32 -
 drivers/staging/ath6kl/include/ar6000_diag.h       |   48 -
 drivers/staging/ath6kl/include/ar6kap_common.h     |   44 -
 drivers/staging/ath6kl/include/athbtfilter.h       |  135 -
 drivers/staging/ath6kl/include/bmi.h               |  134 -
 .../ath6kl/include/common/AR6002/AR6K_version.h    |   52 -
 .../staging/ath6kl/include/common/AR6002/addrs.h   |   90 -
 .../common/AR6002/hw4.0/hw/apb_athr_wlan_map.h     |   40 -
 .../include/common/AR6002/hw4.0/hw/apb_map.h       |   40 -
 .../include/common/AR6002/hw4.0/hw/mbox_host_reg.h |   24 -
 .../include/common/AR6002/hw4.0/hw/mbox_reg.h      |  552 --
 .../common/AR6002/hw4.0/hw/mbox_wlan_host_reg.h    |  471 --
 .../include/common/AR6002/hw4.0/hw/mbox_wlan_reg.h |  589 --
 .../include/common/AR6002/hw4.0/hw/rtc_reg.h       |  187 -
 .../include/common/AR6002/hw4.0/hw/rtc_wlan_reg.h  |  162 -
 .../include/common/AR6002/hw4.0/hw/uart_reg.h      |   40 -
 drivers/staging/ath6kl/include/common/athdefs.h    |   75 -
 drivers/staging/ath6kl/include/common/bmi_msg.h    |  233 -
 drivers/staging/ath6kl/include/common/cnxmgmt.h    |   36 -
 drivers/staging/ath6kl/include/common/dbglog.h     |  126 -
 drivers/staging/ath6kl/include/common/dbglog_id.h  |  558 --
 drivers/staging/ath6kl/include/common/discovery.h  |   75 -
 .../staging/ath6kl/include/common/epping_test.h    |  111 -
 drivers/staging/ath6kl/include/common/gmboxif.h    |   70 -
 drivers/staging/ath6kl/include/common/gpio_reg.h   |    9 -
 drivers/staging/ath6kl/include/common/htc.h        |  227 -
 .../staging/ath6kl/include/common/htc_services.h   |   52 -
 drivers/staging/ath6kl/include/common/pkt_log.h    |   45 -
 drivers/staging/ath6kl/include/common/roaming.h    |   41 -
 drivers/staging/ath6kl/include/common/targaddrs.h  |  395 --
 drivers/staging/ath6kl/include/common/testcmd.h    |  185 -
 drivers/staging/ath6kl/include/common/tlpm.h       |   38 -
 drivers/staging/ath6kl/include/common/wlan_defs.h  |   79 -
 drivers/staging/ath6kl/include/common/wmi.h        | 3220 ----------
 drivers/staging/ath6kl/include/common/wmix.h       |  271 -
 drivers/staging/ath6kl/include/common_drv.h        |  104 -
 drivers/staging/ath6kl/include/dbglog_api.h        |   52 -
 drivers/staging/ath6kl/include/dl_list.h           |  153 -
 drivers/staging/ath6kl/include/dset_api.h          |   65 -
 drivers/staging/ath6kl/include/hci_transport_api.h |  259 -
 drivers/staging/ath6kl/include/hif.h               |  456 --
 drivers/staging/ath6kl/include/host_version.h      |   52 -
 drivers/staging/ath6kl/include/htc_api.h           |  575 --
 drivers/staging/ath6kl/include/htc_packet.h        |  227 -
 drivers/staging/ath6kl/include/wlan_api.h          |  128 -
 drivers/staging/ath6kl/include/wmi_api.h           |  441 --
 drivers/staging/ath6kl/miscdrv/ar3kconfig.c        |  565 --
 .../staging/ath6kl/miscdrv/ar3kps/ar3kpsconfig.c   |  572 --
 .../staging/ath6kl/miscdrv/ar3kps/ar3kpsconfig.h   |   75 -
 .../staging/ath6kl/miscdrv/ar3kps/ar3kpsparser.c   |  969 ---
 .../staging/ath6kl/miscdrv/ar3kps/ar3kpsparser.h   |  113 -
 drivers/staging/ath6kl/miscdrv/common_drv.c        |  910 ---
 drivers/staging/ath6kl/miscdrv/credit_dist.c       |  417 --
 drivers/staging/ath6kl/miscdrv/miscdrv.h           |   42 -
 drivers/staging/ath6kl/os/linux/ar6000_drv.c       | 6267 ------------=
-------
 drivers/staging/ath6kl/os/linux/ar6000_pm.c        |  626 --
 drivers/staging/ath6kl/os/linux/ar6000_raw_if.c    |  455 --
 drivers/staging/ath6kl/os/linux/cfg80211.c         | 1892 ------
 .../staging/ath6kl/os/linux/export_hci_transport.c |  124 -
 drivers/staging/ath6kl/os/linux/hci_bridge.c       | 1141 ----
 .../staging/ath6kl/os/linux/include/ar6000_drv.h   |  776 ---
 drivers/staging/ath6kl/os/linux/include/ar6k_pal.h |   36 -
 .../ath6kl/os/linux/include/ar6xapi_linux.h        |  190 -
 .../staging/ath6kl/os/linux/include/athdrv_linux.h | 1217 ----
 drivers/staging/ath6kl/os/linux/include/cfg80211.h |   61 -
 .../staging/ath6kl/os/linux/include/config_linux.h |   51 -
 .../staging/ath6kl/os/linux/include/debug_linux.h  |   50 -
 .../ath6kl/os/linux/include/export_hci_transport.h |   76 -
 .../ath6kl/os/linux/include/ieee80211_ioctl.h      |  177 -
 .../staging/ath6kl/os/linux/include/osapi_linux.h  |  339 -
 .../staging/ath6kl/os/linux/include/wlan_config.h  |  108 -
 .../ath6kl/os/linux/include/wmi_filter_linux.h     |  300 -
 drivers/staging/ath6kl/os/linux/netbuf.c           |  231 -
 drivers/staging/ath6kl/reorder/aggr_rx_internal.h  |  117 -
 drivers/staging/ath6kl/reorder/rcv_aggr.c          |  661 --
 drivers/staging/ath6kl/wlan/include/ieee80211.h    |  397 --
 .../staging/ath6kl/wlan/include/ieee80211_node.h   |   93 -
 drivers/staging/ath6kl/wlan/src/wlan_node.c        |  636 --
 drivers/staging/ath6kl/wlan/src/wlan_recv_beacon.c |  199 -
 drivers/staging/ath6kl/wlan/src/wlan_utils.c       |   58 -
 drivers/staging/ath6kl/wmi/wmi.c                   | 6444 ------------=
--------
 drivers/staging/ath6kl/wmi/wmi_host.h              |  102 -
 drivers/watchdog/bcm47xx_wdt.c                     |   27 +-
 include/linux/bcma/bcma.h                          |    9 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |   67 +
 include/linux/bcma/bcma_driver_mips.h              |   51 +
 include/linux/bcma/bcma_soc.h                      |   16 +
 include/linux/nl80211.h                            |   61 +-
 include/linux/ssb/ssb_regs.h                       |   40 +
 include/net/cfg80211-wext.h                        |   55 +
 include/net/cfg80211.h                             |  279 +-
 include/net/lib80211.h                             |    3 -
 include/net/mac80211.h                             |   11 -
 net/mac80211/agg-tx.c                              |   18 +-
 net/mac80211/cfg.c                                 |   39 -
 net/mac80211/driver-ops.h                          |   31 -
 net/mac80211/ieee80211_i.h                         |   64 -
 net/mac80211/main.c                                |    1 +
 net/mac80211/mesh_hwmp.c                           |    7 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    8 +-
 net/mac80211/sta_info.c                            |    1 +
 net/mac80211/status.c                              |    3 -
 net/mac80211/tx.c                                  |   20 +
 net/mac80211/util.c                                |  168 +-
 net/wireless/lib80211.c                            |   15 +-
 net/wireless/nl80211.c                             |   86 +-
 net/wireless/reg.c                                 |   14 +-
 net/wireless/scan.c                                |    1 +
 net/wireless/util.c                                |  168 +
 net/wireless/wext-compat.c                         |  137 +-
 net/wireless/wext-compat.h                         |    8 +
 net/wireless/wext-sme.c                            |    3 +-
 321 files changed, 22561 insertions(+), 54152 deletions(-)
 create mode 100644 arch/mips/bcm47xx/Kconfig
 create mode 100644 drivers/bcma/driver_mips.c
 create mode 100644 drivers/bcma/host_soc.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/Kconfig
 create mode 100644 drivers/net/wireless/ath/ath6kl/Makefile
 create mode 100644 drivers/net/wireless/ath/ath6kl/bmi.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/bmi.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/cfg80211.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/cfg80211.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/common.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/core.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/debug.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/debug.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/hif-ops.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/hif.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/htc.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/htc.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/htc_hif.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/htc_hif.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/init.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/main.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/node.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/sdio.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/target.h
 create mode 100644 drivers/net/wireless/ath/ath6kl/txrx.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/wmi.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/wmi.h
 delete mode 100644 drivers/staging/ath6kl/Kconfig
 delete mode 100644 drivers/staging/ath6kl/Makefile
 delete mode 100644 drivers/staging/ath6kl/TODO
 delete mode 100644 drivers/staging/ath6kl/bmi/include/bmi_internal.h
 delete mode 100644 drivers/staging/ath6kl/bmi/src/bmi.c
 delete mode 100644 drivers/staging/ath6kl/hif/common/hif_sdio_common.h
 delete mode 100644 drivers/staging/ath6kl/hif/sdio/linux_sdio/include/=
hif_internal.h
 delete mode 100644 drivers/staging/ath6kl/hif/sdio/linux_sdio/src/hif.=
c
 delete mode 100644 drivers/staging/ath6kl/hif/sdio/linux_sdio/src/hif_=
scatter.c
 delete mode 100644 drivers/staging/ath6kl/htc2/AR6000/ar6k.c
 delete mode 100644 drivers/staging/ath6kl/htc2/AR6000/ar6k.h
 delete mode 100644 drivers/staging/ath6kl/htc2/AR6000/ar6k_events.c
 delete mode 100644 drivers/staging/ath6kl/htc2/AR6000/ar6k_gmbox.c
 delete mode 100644 drivers/staging/ath6kl/htc2/AR6000/ar6k_gmbox_hciua=
rt.c
 delete mode 100644 drivers/staging/ath6kl/htc2/htc.c
 delete mode 100644 drivers/staging/ath6kl/htc2/htc_debug.h
 delete mode 100644 drivers/staging/ath6kl/htc2/htc_internal.h
 delete mode 100644 drivers/staging/ath6kl/htc2/htc_recv.c
 delete mode 100644 drivers/staging/ath6kl/htc2/htc_send.c
 delete mode 100644 drivers/staging/ath6kl/htc2/htc_services.c
 delete mode 100644 drivers/staging/ath6kl/include/a_config.h
 delete mode 100644 drivers/staging/ath6kl/include/a_debug.h
 delete mode 100644 drivers/staging/ath6kl/include/a_drv.h
 delete mode 100644 drivers/staging/ath6kl/include/a_drv_api.h
 delete mode 100644 drivers/staging/ath6kl/include/a_osapi.h
 delete mode 100644 drivers/staging/ath6kl/include/aggr_recv_api.h
 delete mode 100644 drivers/staging/ath6kl/include/ar3kconfig.h
 delete mode 100644 drivers/staging/ath6kl/include/ar6000_api.h
 delete mode 100644 drivers/staging/ath6kl/include/ar6000_diag.h
 delete mode 100644 drivers/staging/ath6kl/include/ar6kap_common.h
 delete mode 100644 drivers/staging/ath6kl/include/athbtfilter.h
 delete mode 100644 drivers/staging/ath6kl/include/bmi.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/AR6K_v=
ersion.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/addrs.=
h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/apb_athr_wlan_map.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/apb_map.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/mbox_host_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/mbox_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/mbox_wlan_host_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/mbox_wlan_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/rtc_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/rtc_wlan_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/AR6002/hw4.0/=
hw/uart_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/athdefs.h
 delete mode 100644 drivers/staging/ath6kl/include/common/bmi_msg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/cnxmgmt.h
 delete mode 100644 drivers/staging/ath6kl/include/common/dbglog.h
 delete mode 100644 drivers/staging/ath6kl/include/common/dbglog_id.h
 delete mode 100644 drivers/staging/ath6kl/include/common/discovery.h
 delete mode 100644 drivers/staging/ath6kl/include/common/epping_test.h
 delete mode 100644 drivers/staging/ath6kl/include/common/gmboxif.h
 delete mode 100644 drivers/staging/ath6kl/include/common/gpio_reg.h
 delete mode 100644 drivers/staging/ath6kl/include/common/htc.h
 delete mode 100644 drivers/staging/ath6kl/include/common/htc_services.=
h
 delete mode 100644 drivers/staging/ath6kl/include/common/pkt_log.h
 delete mode 100644 drivers/staging/ath6kl/include/common/roaming.h
 delete mode 100644 drivers/staging/ath6kl/include/common/targaddrs.h
 delete mode 100644 drivers/staging/ath6kl/include/common/testcmd.h
 delete mode 100644 drivers/staging/ath6kl/include/common/tlpm.h
 delete mode 100644 drivers/staging/ath6kl/include/common/wlan_defs.h
 delete mode 100644 drivers/staging/ath6kl/include/common/wmi.h
 delete mode 100644 drivers/staging/ath6kl/include/common/wmix.h
 delete mode 100644 drivers/staging/ath6kl/include/common_drv.h
 delete mode 100644 drivers/staging/ath6kl/include/dbglog_api.h
 delete mode 100644 drivers/staging/ath6kl/include/dl_list.h
 delete mode 100644 drivers/staging/ath6kl/include/dset_api.h
 delete mode 100644 drivers/staging/ath6kl/include/hci_transport_api.h
 delete mode 100644 drivers/staging/ath6kl/include/hif.h
 delete mode 100644 drivers/staging/ath6kl/include/host_version.h
 delete mode 100644 drivers/staging/ath6kl/include/htc_api.h
 delete mode 100644 drivers/staging/ath6kl/include/htc_packet.h
 delete mode 100644 drivers/staging/ath6kl/include/wlan_api.h
 delete mode 100644 drivers/staging/ath6kl/include/wmi_api.h
 delete mode 100644 drivers/staging/ath6kl/miscdrv/ar3kconfig.c
 delete mode 100644 drivers/staging/ath6kl/miscdrv/ar3kps/ar3kpsconfig.=
c
 delete mode 100644 drivers/staging/ath6kl/miscdrv/ar3kps/ar3kpsconfig.=
h
 delete mode 100644 drivers/staging/ath6kl/miscdrv/ar3kps/ar3kpsparser.=
c
 delete mode 100644 drivers/staging/ath6kl/miscdrv/ar3kps/ar3kpsparser.=
h
 delete mode 100644 drivers/staging/ath6kl/miscdrv/common_drv.c
 delete mode 100644 drivers/staging/ath6kl/miscdrv/credit_dist.c
 delete mode 100644 drivers/staging/ath6kl/miscdrv/miscdrv.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/ar6000_drv.c
 delete mode 100644 drivers/staging/ath6kl/os/linux/ar6000_pm.c
 delete mode 100644 drivers/staging/ath6kl/os/linux/ar6000_raw_if.c
 delete mode 100644 drivers/staging/ath6kl/os/linux/cfg80211.c
 delete mode 100644 drivers/staging/ath6kl/os/linux/export_hci_transpor=
t.c
 delete mode 100644 drivers/staging/ath6kl/os/linux/hci_bridge.c
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/ar6000_drv.=
h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/ar6k_pal.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/ar6xapi_lin=
ux.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/athdrv_linu=
x.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/cfg80211.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/config_linu=
x.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/debug_linux=
=2Eh
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/export_hci_=
transport.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/ieee80211_i=
octl.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/osapi_linux=
=2Eh
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/wlan_config=
=2Eh
 delete mode 100644 drivers/staging/ath6kl/os/linux/include/wmi_filter_=
linux.h
 delete mode 100644 drivers/staging/ath6kl/os/linux/netbuf.c
 delete mode 100644 drivers/staging/ath6kl/reorder/aggr_rx_internal.h
 delete mode 100644 drivers/staging/ath6kl/reorder/rcv_aggr.c
 delete mode 100644 drivers/staging/ath6kl/wlan/include/ieee80211.h
 delete mode 100644 drivers/staging/ath6kl/wlan/include/ieee80211_node.=
h
 delete mode 100644 drivers/staging/ath6kl/wlan/src/wlan_node.c
 delete mode 100644 drivers/staging/ath6kl/wlan/src/wlan_recv_beacon.c
 delete mode 100644 drivers/staging/ath6kl/wlan/src/wlan_utils.c
 delete mode 100644 drivers/staging/ath6kl/wmi/wmi.c
 delete mode 100644 drivers/staging/ath6kl/wmi/wmi_host.h
 create mode 100644 include/linux/bcma/bcma_driver_mips.h
 create mode 100644 include/linux/bcma/bcma_soc.h
 create mode 100644 include/net/cfg80211-wext.h

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
011-08-22.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
