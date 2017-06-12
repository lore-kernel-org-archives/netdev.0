From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-06-12
Date: Mon, 12 Jun 2017 16:31:23 +0300
Message-ID: <87poe98h90.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request to net-next, more info in the tag below. But do
note that Stephen reported qtnfmac will fail to build with the net tree
due to the changes in netdev destructor:

https://lkml.kernel.org/r/20170608122759.7ffda0c3@canb.auug.org.au

So once you pull these changes AND your net tree to net-next you need to
apply Stephen's patch above. As of this writing there is no build
breakage (yet).

Please let me know if there are any problems.

Kalle

The following changes since commit a95cfad947d5f40cfbf9ad3019575aac1d8ac7a6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-05-15 15:50:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2017-06-12

for you to fetch changes up to 219569ad0c41df7a7f999a2cad688c6b6ce173e2:

  rsi: use subdirectory for firmware file (2017-06-01 12:51:19 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.13

The first pull request for 4.13. We have a new driver qtnfmac, but
also rsi driver got a support for new firmware and supporting ath10k
SDIO devices was started.

Major changes:

ath10k

* add initial SDIO support (still work in progress)

rsi

* new loading for the new firmware version

rtlwifi

* final patches for the new btcoex support

rt2x00

* add device ID for Epson WN7512BEP

qtnfmac

* new driver for Quantenna QSR10G chipsets

----------------------------------------------------------------
Ammly Fredrick (1):
      ath9k: fix spelling in ath9k_tx99_init()

Arend Van Spriel (2):
      brcmfmac: move scheduled scan wiphy param setting to pno module
      ath6kl: assure headroom of skbuff is writable in .start_xmit()

Arend van Spriel (1):
      brcmfmac: add firmware feature detection for gscan feature

Arnd Bergmann (11):
      wlcore: fix 64K page support
      rt2x00: change function pointers for register accessors
      rt2x00: convert rt2800_rfcsr_read return type
      rt2x00: convert rt2x00_rf_read return type
      rt2x00: convert rt2x00mmio_register_read return type
      rt2x00: convert rt2x00usb_register_read return type
      rt2x00: convert rt2800_register_read return type
      rt2x00: convert rt2*_bbp_read return type
      rt2x00: convert rt2x00_eeprom_read return type
      rt2x00: convert rt2800_eeprom_read return type
      rt2x00: convert rt2x00_desc_read return type

Brian Norris (11):
      mwifiex: initiate card-specific work atomically
      mwifiex: pcie: add card_reset() support
      mwifiex: pcie: de-duplicate buffer allocation code
      mwifiex: fixup error cases in mwifiex_add_virtual_intf()
      mwifiex: don't drop lock between list-retrieval / list-deletion
      mwifiex: don't leak stashed beacon buffer on reset
      mwifiex: remove useless 'mwifiex_lock'
      mwifiex: remove redundant 'adapter' check in mwifiex_adapter_cleanup
      mwifiex: 11h: drop unnecessary check for '!priv'
      mwifiex: pcie: remove useless pdev check
      mwifiex: pcie: stop setting/clearing 'surprise_removed'

Chi-hsien Lin (1):
      brcmfmac: remove setting IBSS mode when stopping AP

Colin Ian King (4):
      rtlwifi: fix spelling mistake: "Pairwiase" -> "Pairwise"
      rtlwifi: rtl8723ae: fix spelling mistake: "Coexistance" -> "Coexistence"
      ath5k: fix memory leak on buf on failed eeprom read
      qtnfmac: remove duplicated assignment to mac

Dan Carpenter (2):
      p54: allocate enough space for ->used_rxkeys
      rtlwifi: btcoex: 23b 1ant: initialize bt_disabled to false

Douglas Anderson (3):
      mwifiex: Don't release tx_ba_stream_tbl_lock while iterating
      mwifiex: Don't release cmd_pending_q_lock while iterating
      mwifiex: Add locking to mwifiex_11n_delba

Elena Reshetova (2):
      hostap: convert hostap_cmd_queue.usecnt from atomic_t to refcount_t
      orinoco_usb: convert request_context.refcount from atomic_t to refcount_t

Erik Stromdahl (10):
      ath10k: htc: made static function public
      ath10k: htc: rx trailer lookahead support
      ath10k: htc: move htc ctrl ep connect to htc_init
      ath10k: htc: refactorization
      ath10k: various sdio related definitions
      ath10k: add sdio extra initializations
      ath10k: sdio get target info
      ath10k: htc: ready_ext msg support
      ath10k: different fw file name for sdio
      ath10k: add initial SDIO support

Geliang Tang (2):
      wlcore: use memdup_user
      wil6210: use memdup_user

Gustavo A. R. Silva (1):
      ath9k: remove unnecessary code

Igor Mitsyanko (1):
      qtnfmac: introduce new FullMAC driver for Quantenna chipsets

Johan Hovold (1):
      mwifiex: add missing USB-descriptor endianness conversion

Kalle Valo (1):
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karim Eshapa (1):
      rsi: rsi_91x_core: Use time_after time comparison

Kees Cook (3):
      ray_cs: Avoid reading past end of buffer
      libertas: Avoid reading past end of buffer
      libertas: Remove function entry/exit debugging

Larry Finger (5):
      rtlwifi: btcoex: Remove 21a 1ant configuration parameter
      rtlwifi: btcoex: Remove 23b 1ant configuration parameter
      rtlwifi: btcoex: Remove 23b 2ant configuration parameter
      rtlwifi: btcoex: Remove 92e 2ant configuration parameter
      rtlwifi: btcoex: Restore 23b 1ant routine for tdma adjustment

Markus Elfring (1):
      ssb: Delete an error message for a failed memory allocation in ssb_devices_register()

Michael Mera (1):
      ath10k: fix out of bounds access to local buffer

Ping-Ke Shih (25):
      rtlwifi: btcoex: 23b 1ant: rename and coding style modification.
      rtlwifi: btcoex: 23b 1ant: TDMA duration for ACL busy
      rtlwifi: btcoex: 23b 1ant: monitor wifi and BT counter
      rtlwifi: btcoex: 23b 1ant: check if BT high priority packet exist
      rtlwifi: btcoex: 23b 1ant: monitor bt is enabled or disabled
      rtlwifi: btcoex: 23b 1ant: check PS state before setting tdma duration
      rtlwifi: btcoex: 23b 1ant: Switch antenna to wifi or BT.
      rtlwifi: btcoex: 23b 1ant: need these information when scan
      rtlwifi: btcoex: 23b 1ant: adjust wifi duration for bt a2dp
      rtlwifi: btcoex: 23b 1ant: add wifi_only argument to init_hwconfig
      rtlwifi: btcoex: 23b 1ant: Add power_on_setting
      rtlwifi: btcoex: 23b 1ant: parse more BT information from C2H
      rtlwifi: btcoex: 23b 1ant: Setup register for BT WHCK test
      rtlwifi: btcoex: 23b 1ant: Add rf status notification
      rtlwifi: btcoex: 23b 1ant: fine tune connect notify
      rtlwifi: btcoex: 23b 1ant: Revise media status notify to fix no scan result issue
      rtlwifi: btcoex: 23b 1ant: Special packets statistic in notification
      rtlwifi: btcoex: 23b 1ant: define wifi in high priority task.
      rtlwifi: btcoex: 23b 1ant: check more cases when bt is queing
      rtlwifi: btcoex: 23b 1ant: remove verbose log from periodic function
      rtlwifi: btcoex: 23b 1ant: Add coex_table_type to log
      rtlwifi: btcoex: 23b 1ant: coex table fine tune
      rtlwifi: btcoex: 23b 1ant: fine tune for wifi connected
      rtlwifi: btcoex: 23b 1ant: fine tune for wifi not connected
      rtlwifi: btcoex: 23b 1ant: fine tune for bt_sco_hid busy

Prameela Rani Garnepudi (10):
      rsi: Rename file rsi_91x_pkt.c to rsi_91x_hal.c
      rsi: Changes to sdio reads and writes
      rsi: Changes in USB read and write operations
      rsi: use macros in USB specific code
      rsi: Handle usb multi-byte write failure case properly
      rsi: Add usb multi-byte read operation
      rsi: Add host interface operations as separate structure.
      rsi: Add new host interface operations
      rsi: Add new firmware loading method
      rsi: Remove old firmware loading method

Ryan Hsu (1):
      ath10k: append the wmi_op_version to testmode get_version cmd

Shawn Lin (1):
      mwifiex: simplify the code around ra_list

Stanislaw Gruszka (2):
      ath9k: check ah->curchan when updating tx power
      iwlegacy: warn when enabling power save

Takashi Iwai (1):
      b43: Add missing MODULE_FIRMWARE()

Tom Gaudasinski (1):
      rt2x00: Add device ID for Epson WN7512BEP

Xie Qirong (1):
      brcmfmac: btcoex: replace init_timer with setup_timer

Xinming Hu (7):
      mwifiex: p2p client using same data path as station
      mwifiex: use variable interface header length
      mwifiex: usb: kill urb before free its memory
      mwifiex: usb: transmit aggregation packets
      mwifiex: usb: add timer to flush aggregation packets
      mwifiex: check next packet length for usb tx aggregation
      mwifiex: uap: process remain on channel expired event

Yan-Hsuan Chuang (24):
      rtlwifi: btcoex: 21a 2ant: set tdma with rssi states
      rtlwifi: btcoex: 21a 2ant: refine btc8821a2ant_action_hid_a2dp
      rtlwifi: btcoex: 21a 2ant: set wifi standby when halting of entering ips
      rtlwifi: btcoex: 21a 2ant: settings before wifi firmware is ready
      rtlwifi: btcoex: 21a 2ant: add pnp notidy to avoid LPS/IPS mismatch
      rtlwifi: btcoex: 21a 2ant: run mechanism if status changes or auto adjust is set
      rtlwifi: btcoex: 21a 2ant: init wlan when leave ips
      rtlwifi: btcoex: 21a 2ant: refine bt info notify to have more profilings
      rtlwifi: btcoex: 21a 2ant: fix PTA unstable problem when hw init
      rtlwifi: btcoex: 21a 2ant: remove unused antenna detection variables
      rtlwifi: btcoex: 21a 1ant: set tdma and coex table when wifi is idle
      rtlwifi: btcoex: 21a 1ant: more bt profiling when wifi receives special packet
      rtlwifi: btcoex: 21a 1ant: shorten wifi slot when connected scan
      rtlwifi: btcoex: 21a 1ant: react to special packet when wifi is not scanning
      rtlwifi: btcoex: 21a 1ant: coex table and tdma settings for softap mode
      rtlwifi: btcoex: 21a 1ant: wifi slot time adjustment
      rtlwifi: btcoex: 21a 1ant: normal mode for retry limit when connected
      rtlwifi: btcoex: 21a 1ant: mark packet high priority when scanning
      rtlwifi: btcoex: 21a 1ant: use default value when initiating coex
      rtlwifi: btcoex: 21a 1ant: re-init coex after wifi leaves IPS
      rtlwifi: btcoex: 21a 1ant: treat ARP as special packet
      rtlwifi: btcoex: 21a 1ant: fix some coding style issues
      rtlwifi: btcoex: 21a 1ant: add bt_tx_rx_mask into bt info
      rtlwifi: btcoex: 23b 1ant: turn off ps and tdma mechanism when concurrent mode

amit karwar (2):
      rsi: define RSI_USB_BUF_SIZE macro
      rsi: use subdirectory for firmware file

 MAINTAINERS                                        |    8 +
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    1 +
 drivers/net/wireless/ath/ath10k/Kconfig            |    7 +
 drivers/net/wireless/ath/ath10k/Makefile           |    3 +
 drivers/net/wireless/ath/ath10k/bmi.c              |   71 +
 drivers/net/wireless/ath/ath10k/bmi.h              |    2 +
 drivers/net/wireless/ath/ath10k/core.c             |   36 +-
 drivers/net/wireless/ath/ath10k/core.h             |    3 +
 drivers/net/wireless/ath/ath10k/debug.c            |   16 +-
 drivers/net/wireless/ath/ath10k/debug.h            |    2 +
 drivers/net/wireless/ath/ath10k/htc.c              |  244 ++-
 drivers/net/wireless/ath/ath10k/htc.h              |   39 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   53 +
 drivers/net/wireless/ath/ath10k/sdio.c             | 2113 ++++++++++++++++++++
 drivers/net/wireless/ath/ath10k/sdio.h             |  229 +++
 drivers/net/wireless/ath/ath10k/targaddrs.h        |   24 +
 drivers/net/wireless/ath/ath10k/testmode.c         |    7 +
 drivers/net/wireless/ath/ath10k/testmode_i.h       |    1 +
 drivers/net/wireless/ath/ath5k/debug.c             |    5 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |   13 +-
 drivers/net/wireless/ath/ath9k/common.c            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    2 +-
 drivers/net/wireless/ath/ath9k/tx99.c              |    2 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   12 +-
 drivers/net/wireless/broadcom/b43/main.c           |   10 +
 .../wireless/broadcom/brcm80211/brcmfmac/btcoex.c  |    4 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   21 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |    2 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |   22 +-
 .../wireless/broadcom/brcm80211/brcmfmac/feature.h |    4 +-
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |   59 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.c |   10 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.h |    8 +
 drivers/net/wireless/intel/iwlegacy/common.c       |    2 +
 drivers/net/wireless/intel/iwlegacy/common.h       |    1 +
 drivers/net/wireless/intersil/hostap/hostap_hw.c   |   12 +-
 drivers/net/wireless/intersil/hostap/hostap_wlan.h |    3 +-
 .../net/wireless/intersil/orinoco/orinoco_usb.c    |   15 +-
 drivers/net/wireless/intersil/p54/fwio.c           |    5 +-
 drivers/net/wireless/marvell/libertas/cfg.c        |  104 +-
 drivers/net/wireless/marvell/libertas/cmd.c        |  116 +-
 drivers/net/wireless/marvell/libertas/cmdresp.c    |    9 -
 drivers/net/wireless/marvell/libertas/defs.h       |    9 -
 drivers/net/wireless/marvell/libertas/ethtool.c    |    3 -
 drivers/net/wireless/marvell/libertas/if_cs.c      |   36 -
 drivers/net/wireless/marvell/libertas/if_sdio.c    |   66 +-
 drivers/net/wireless/marvell/libertas/if_spi.c     |   38 +-
 drivers/net/wireless/marvell/libertas/if_usb.c     |   27 +-
 drivers/net/wireless/marvell/libertas/main.c       |   81 +-
 drivers/net/wireless/marvell/libertas/mesh.c       |   54 +-
 drivers/net/wireless/marvell/libertas/rx.c         |    6 -
 drivers/net/wireless/marvell/libertas/tx.c         |    3 -
 drivers/net/wireless/marvell/mwifiex/11h.c         |    6 -
 drivers/net/wireless/marvell/mwifiex/11n.c         |   17 +-
 drivers/net/wireless/marvell/mwifiex/11n_aggr.c    |   14 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   71 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |   15 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   10 +
 drivers/net/wireless/marvell/mwifiex/init.c        |   17 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |    4 +
 drivers/net/wireless/marvell/mwifiex/main.h        |   21 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  207 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   28 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   18 +
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   24 +
 drivers/net/wireless/marvell/mwifiex/sta_tx.c      |   12 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |    7 +-
 drivers/net/wireless/marvell/mwifiex/txrx.c        |   15 +-
 drivers/net/wireless/marvell/mwifiex/uap_event.c   |   11 +
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c    |    5 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |  585 ++++--
 drivers/net/wireless/marvell/mwifiex/usb.h         |   23 +
 drivers/net/wireless/marvell/mwifiex/wmm.c         |   16 +-
 drivers/net/wireless/quantenna/Kconfig             |   16 +
 drivers/net/wireless/quantenna/Makefile            |    6 +
 drivers/net/wireless/quantenna/qtnfmac/Kconfig     |   19 +
 drivers/net/wireless/quantenna/qtnfmac/Makefile    |   31 +
 drivers/net/wireless/quantenna/qtnfmac/bus.h       |  139 ++
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c  |  995 +++++++++
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.h  |   43 +
 drivers/net/wireless/quantenna/qtnfmac/commands.c  | 1982 ++++++++++++++++++
 drivers/net/wireless/quantenna/qtnfmac/commands.h  |   74 +
 drivers/net/wireless/quantenna/qtnfmac/core.c      |  618 ++++++
 drivers/net/wireless/quantenna/qtnfmac/core.h      |  173 ++
 drivers/net/wireless/quantenna/qtnfmac/debug.c     |   46 +
 drivers/net/wireless/quantenna/qtnfmac/debug.h     |   50 +
 drivers/net/wireless/quantenna/qtnfmac/event.c     |  452 +++++
 drivers/net/wireless/quantenna/qtnfmac/event.h     |   27 +
 .../net/wireless/quantenna/qtnfmac/pearl/pcie.c    | 1378 +++++++++++++
 .../quantenna/qtnfmac/pearl/pcie_bus_priv.h        |   89 +
 .../wireless/quantenna/qtnfmac/pearl/pcie_ipc.h    |  158 ++
 .../quantenna/qtnfmac/pearl/pcie_regs_pearl.h      |  353 ++++
 drivers/net/wireless/quantenna/qtnfmac/qlink.h     |  901 +++++++++
 .../net/wireless/quantenna/qtnfmac/qlink_util.c    |   71 +
 .../net/wireless/quantenna/qtnfmac/qlink_util.h    |   80 +
 .../net/wireless/quantenna/qtnfmac/qtn_hw_ids.h    |   32 +
 drivers/net/wireless/quantenna/qtnfmac/shm_ipc.c   |  176 ++
 drivers/net/wireless/quantenna/qtnfmac/shm_ipc.h   |   80 +
 .../net/wireless/quantenna/qtnfmac/shm_ipc_defs.h  |   46 +
 drivers/net/wireless/quantenna/qtnfmac/trans.c     |  224 +++
 drivers/net/wireless/quantenna/qtnfmac/trans.h     |   57 +
 drivers/net/wireless/quantenna/qtnfmac/util.c      |  114 ++
 drivers/net/wireless/quantenna/qtnfmac/util.h      |   45 +
 drivers/net/wireless/ralink/rt2x00/rt2400pci.c     |  181 +-
 drivers/net/wireless/ralink/rt2x00/rt2500pci.c     |  195 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |  173 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |  911 ++++-----
 drivers/net/wireless/ralink/rt2x00/rt2800lib.h     |   22 +-
 drivers/net/wireless/ralink/rt2x00/rt2800mmio.c    |   44 +-
 drivers/net/wireless/ralink/rt2x00/rt2800pci.c     |    6 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c     |   20 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |   12 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.c   |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.h   |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00mmio.c    |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00mmio.h    |    7 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.h   |   12 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c     |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.h     |   16 +-
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |  285 +--
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |  189 +-
 drivers/net/wireless/ray_cs.c                      |    7 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    |   68 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.h    |    2 -
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    | 2043 ++++++++++++++-----
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.h    |   47 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    |   80 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.h    |    2 -
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |  275 ++-
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.h    |    4 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    |  515 +++--
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.h    |   10 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |   28 +
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |    2 +-
 drivers/net/wireless/rsi/Makefile                  |    2 +-
 drivers/net/wireless/rsi/rsi_91x_core.c            |    2 +-
 drivers/net/wireless/rsi/rsi_91x_hal.c             |  740 +++++++
 drivers/net/wireless/rsi/rsi_91x_pkt.c             |  215 --
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |  211 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c        |  190 +-
 drivers/net/wireless/rsi/rsi_91x_usb.c             |  166 +-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c         |  125 --
 drivers/net/wireless/rsi/rsi_common.h              |    3 +-
 drivers/net/wireless/rsi/rsi_hal.h                 |   81 +
 drivers/net/wireless/rsi/rsi_main.h                |   36 +-
 drivers/net/wireless/rsi/rsi_sdio.h                |    6 +-
 drivers/net/wireless/rsi/rsi_usb.h                 |    5 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |   13 +-
 drivers/net/wireless/ti/wlcore/spi.c               |    6 +-
 drivers/ssb/main.c                                 |    1 -
 153 files changed, 16692 insertions(+), 3509 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath10k/sdio.c
 create mode 100644 drivers/net/wireless/ath/ath10k/sdio.h
 create mode 100644 drivers/net/wireless/quantenna/Kconfig
 create mode 100644 drivers/net/wireless/quantenna/Makefile
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/Kconfig
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/Makefile
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/bus.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/cfg80211.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/commands.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/commands.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/core.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/core.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/debug.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/debug.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/event.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/event.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_bus_priv.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_ipc.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_regs_pearl.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/qlink.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/qlink_util.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/qtn_hw_ids.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/shm_ipc.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/shm_ipc.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/shm_ipc_defs.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/trans.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/trans.h
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/util.c
 create mode 100644 drivers/net/wireless/quantenna/qtnfmac/util.h
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_hal.c
 delete mode 100644 drivers/net/wireless/rsi/rsi_91x_pkt.c
 create mode 100644 drivers/net/wireless/rsi/rsi_hal.h
