From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-10-18
Date: Wed, 18 Oct 2017 12:42:31 +0300
Message-ID: <87fuagiygo.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

this for 4.15 stream to net-next tree. Please let me know if there are
any problems.

Kalle

The following changes since commit 3e747fa18202896b5be66b88478352d5880fb8eb:

  Merge ath-current from ath.git (2017-09-25 10:06:12 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-10-18

for you to fetch changes up to 66cc044249603e12e1dbba347f03bdbc9f171fdf:

  bcma: use bcma_debug and pr_cont in MIPS driver (2017-10-17 17:22:07 +030=
0)

----------------------------------------------------------------
wireless-drivers-next patches for 4.15

The first pull request for 4.15, unusually late this time but still
relatively small. Also includes merge from wireless-drivers to fix
conflicts in iwlwifi.

Major changes:

rsi

* add P2P mode support

* sdio suspend and resume support

iwlwifi

* A fix and an addition for PCI devices for the A000 family

* Dump PCI registers when an error occurs, to make it easier to debug

rtlwifi

* add support for 64 bit DMA, enabled with a module parameter

* add module parameter to enable ASPM

----------------------------------------------------------------
Adam Borowski (1):
      rtl8xxxu: Don't printk raw binary if serial number is not burned in.

Allen Pais (1):
      brcmfmac: use setup_timer() helper

Andrey Konovalov (1):
      p54: don't unregister leds when they are not initialized

Arnd Bergmann (2):
      brcmsmac: make some local variables 'static const' to reduce stack si=
ze
      rsi: fix integer overflow warning

Chaya Rachel Ivgi (2):
      iwlwifi: nvm: set the correct offsets to 3168 series
      iwlwifi: remove redundant reading from NVM file

Christoph B=C3=B6hmwalder (1):
      iwlwifi: fix minor code style issues

Christos Gkekas (1):
      rtlwifi: Remove unused cur_rfstate variables

Colin Ian King (8):
      rsi: fix a dereference on adapter before it has been null checked
      b43: fix unitialized reads of ret by initializing the array to zero
      b43legacy: fix unitialized reads of ret by initializing the array to =
zero
      mwifiex: make const arrays static to shink object code size
      brcmsmac: make const array ucode_ofdm_rates static, reduces object co=
de size
      mwifiex: make const array tos_to_ac static, reduces object code size
      iwlegacy: make const array static to shink object code size
      b43: make const arrays static, reduces object code size

Dan Carpenter (1):
      rtlwifi: silence underflow warning

David Spinadel (1):
      iwlwifi: mvm: Add new quota command API

Douglas Anderson (2):
      mwifiex: kill useless list_empty checks
      mwifiex: minor cleanups w/ sta_list_spinlock in cfg80211.c

Emmanuel Grumbach (3):
      iwlwifi: mvm: remove support for Link Quality Measurements
      iwlwifi: mvm: support firmware debug trigger on frame reorder timeout
      iwlwifi: mvm: don't send identical PHY_CTXT_CMD

Ganapathi Bhat (4):
      mwifiex: notify cfg80211 about scan abort
      mwifiex: check for mfg_mode in add_virtual_intf
      mwifiex: avoid storing random_mac in private
      mwifiex: use get_random_mask_addr() helper

Golan Ben Ami (1):
      iwlwifi: stop dbgc recording before stopping DMA

Himanshu Jha (2):
      mwifiex: remove unnecessary call to memset
      mwifiex: Use put_unaligned_le32

Igor Mitsyanko (17):
      qtnfmac: convert channel width from bitfiled to simple enum
      qtnfmac: make "Channel change" event report full channel info
      qtnfmac: retrieve current channel info from EP
      qtnfmac: do not cache channel info from "connect" command
      qtnfmac: let wifi card handle channel switch request to the same chan
      qtnfmac: pass VIF info to SendChannel command
      qtnfmac: do not cache CSA chandef info
      qtnfmac: remove unused mac::status field
      qtnfmac: do not report channel changes until wiphy is registered
      qtnfmac: do not cache AP settings in driver structures
      qtnfmac: pass all AP settings to wireless card for processing
      qtnfmac: pass channel definition to WiFi card on START_AP command
      qtnfmac: get rid of QTNF_STATE_AP_CONFIG
      qtnfmac: get rid of QTNF_STATE_AP_START flag
      qtnfmac: do not cache BSS state in per-VIF structure
      qtnfmac: make encryption info a part of CONNECT command.
      qtnfmac: do not cache current channel info in driver's state

Ilan Peer (1):
      iwlwifi: Add few debug prints to the WRT dump flow

Johannes Berg (4):
      iwlwifi: nvm-parse: unify channel flags printing
      iwlwifi: fw: api: remove excess enum value documentation
      iwlwifi: fix indentation in a000 family configuration
      iwlwifi: mvm: warn on invalid statistics size

Kalle Valo (3):
      Merge tag 'iwlwifi-for-kalle-2017-10-06' of git://git.kernel.org/.../=
iwlwifi/iwlwifi-fixes
      Merge tag 'iwlwifi-next-for-kalle-2017-10-06-2' of git://git.kernel.o=
rg/.../iwlwifi/iwlwifi-next
      Merge git://git.kernel.org/.../kvalo/wireless-drivers.git

Karthik Ananthapadmanabha (1):
      mwifiex: Random MAC address during scanning

Karun Eagalapati (1):
      rsi: sdio suspend and resume support

Kevin Cernekee (3):
      brcmfmac: Add check for short event packets
      brcmfmac: Avoid possible out-of-bounds read
      brcmfmac: Delete redundant length check

Larry Finger (4):
      rtlwifi: btcoexist: 23b 1ant: fix duplicated code for different branc=
hes
      rtlwifi: rtl8192ee: Fix memory leak when loading firmware
      rtlwifi: rtl8821ae: Fix connection lost problem
      rtlwifi: Fix typo in if ... else if ... else construct

Liad Kaufman (1):
      iwlwifi: mvm: add dbgfs entry for fw info

Luca Coelho (12):
      iwlwifi: mvm: return -ENODATA when reading the temperature with the F=
W down
      iwlwifi: trans: move ref/unref code to the common part of the transpo=
rt
      iwlwifi: acpi: add common code to read from ACPI
      iwlwifi: acpi: move ACPI method definitions to acpi.h
      iwlwifi: acpi: move ACPI-related definitions to acpi.h
      iwlwifi: acpi: generalize iwl_mvm_sar_find_wifi_pkg()
      iwlwifi: acpi: use iwl_acpi_get_wifi_pkg when reading reading SPLC
      iwlwifi: acpi: make iwl_get_bios_mcc() use the common acpi functions
      iwlwifi: acpi: remove a couple of unnecessary ifdefs
      iwlwifi: acpi: move function to get mcc into acpi code
      iwlwifi: acpi: move code that reads SPLC to acpi
      iwlwifi: remove dflt_pwr_limit from the transport

Mordechay Goodstein (1):
      iwlwifi: mvm: add marker cmd response struct.

Oren Givon (2):
      iwlwifi: fix wrong struct for a000 device
      iwlwifi: add a new a000 device

Pavani Muthyala (1):
      rsi: add version information

Ping-Ke Shih (10):
      rtlwifi: Fix MAX MPDU of VHT capability
      rtlwifi: Remove redundant semicolon in wifi.h.
      rtlwifi: rtl8192ee: Make driver support 64bits DMA.
      rtlwifi: Implement rtl_get_tx_hw_rate to yield correct hw_rate
      rtlwifi: Add rtl_get_hal_edca_param() to generate register's format o=
f EDCA.
      rtlwifi: Add TX/RX throughput statistics in period
      rtlwifi: Add RSSI and RF type to wifi.h for phydm
      rtlwifi: Remove BAND_NUM and related fields
      rtlwifi: Add bw_update parameter for RA mask update.
      rtlwifi: Add module parameter ASPM

Prameela Rani Garnepudi (8):
      rsi: add p2p support parameters to mac80211
      rsi: add/remove interface enhancements for p2p
      rsi: add support for p2p listen
      rsi: handle peer connection and disconnection in p2p mode
      rsi: tx and rx path enhancements for p2p mode
      rsi: disallow power save config when AP vap running
      rsi: aggregation changes for p2p mode
      rsi: miscellaneous changes for p2p mode

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: use bcma_debug and pr_cont in MIPS driver

Rajat Jain (1):
      iwlwifi: pcie: dump registers when HW becomes inaccessible

Randy Dunlap (1):
      bcma: keep *config menu together

Rohit Fule (1):
      mwifiex: double the size of chan_stats array in adapter

Sara Sharon (1):
      iwlwifi: mvm: change warning to warn_once()

Shahar S Matityahu (1):
      iwlwifi: pcie: dynamic Tx command queue size

Shaul Triebitz (1):
      iwlwifi: mvm: do not print security error in monitor mode

 drivers/bcma/Kconfig                               |  18 +-
 drivers/bcma/driver_mips.c                         |   7 +-
 drivers/net/wireless/broadcom/b43/phy_g.c          |   2 +-
 drivers/net/wireless/broadcom/b43/phy_ht.c         |   6 +-
 drivers/net/wireless/broadcom/b43legacy/radio.c    |   2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |   8 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   3 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   6 +-
 .../broadcom/brcm80211/brcmsmac/phy/phy_cmn.c      |   2 +-
 .../broadcom/brcm80211/brcmsmac/phy/phy_n.c        | 197 +++++----
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |   2 +-
 drivers/net/wireless/intel/iwlwifi/Makefile        |   1 +
 drivers/net/wireless/intel/iwlwifi/cfg/7000.c      |   1 +
 drivers/net/wireless/intel/iwlwifi/cfg/8000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/a000.c      | 105 ++---
 drivers/net/wireless/intel/iwlwifi/fw/acpi.c       | 210 ++++++++++
 drivers/net/wireless/intel/iwlwifi/fw/acpi.h       | 138 +++++++
 .../net/wireless/intel/iwlwifi/fw/api/binding.h    |  41 +-
 .../net/wireless/intel/iwlwifi/fw/api/commands.h   |   1 +
 drivers/net/wireless/intel/iwlwifi/fw/api/debug.h  |   9 +
 .../net/wireless/intel/iwlwifi/fw/api/mac-cfg.h    |  67 ----
 .../net/wireless/intel/iwlwifi/fw/api/nvm-reg.h    |   2 +
 drivers/net/wireless/intel/iwlwifi/fw/api/power.h  |   3 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/sta.h    |   4 -
 drivers/net/wireless/intel/iwlwifi/fw/dbg.c        |  22 +-
 drivers/net/wireless/intel/iwlwifi/fw/dbg.h        |  15 +
 drivers/net/wireless/intel/iwlwifi/fw/file.h       |   3 +
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |  19 +-
 drivers/net/wireless/intel/iwlwifi/iwl-debug.h     |   1 +
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c | 228 +++--------
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h |  17 -
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |  16 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |  16 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  16 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |  76 ----
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |  32 ++
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        | 207 ++--------
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  59 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  67 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |  24 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  22 +-
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/quota.c     |  59 +--
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |  11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  12 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  96 ++---
 .../net/wireless/intel/iwlwifi/pcie/ctxt-info.c    |   2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      | 100 +----
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   4 +
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  89 ++++
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c  |   8 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |  23 +-
 drivers/net/wireless/intersil/p54/main.c           |   7 +-
 drivers/net/wireless/marvell/mwifiex/11n.c         |   9 -
 .../net/wireless/marvell/mwifiex/11n_rxreorder.c   |   6 -
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |  76 ++--
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |  10 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   1 +
 drivers/net/wireless/marvell/mwifiex/init.c        |   4 -
 drivers/net/wireless/marvell/mwifiex/main.h        |   1 -
 drivers/net/wireless/marvell/mwifiex/scan.c        |   5 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   6 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |   6 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |   7 -
 drivers/net/wireless/marvell/mwifiex/wmm.c         |   3 +-
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c  | 173 ++------
 drivers/net/wireless/quantenna/qtnfmac/commands.c  | 215 ++++++----
 drivers/net/wireless/quantenna/qtnfmac/commands.h  |   6 +-
 drivers/net/wireless/quantenna/qtnfmac/core.h      |  30 +-
 drivers/net/wireless/quantenna/qtnfmac/event.c     |  48 +--
 drivers/net/wireless/quantenna/qtnfmac/qlink.h     | 137 +++++--
 .../net/wireless/quantenna/qtnfmac/qlink_util.c    | 113 +++++-
 .../net/wireless/quantenna/qtnfmac/qlink_util.h    |   7 +
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |   5 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        | 104 ++++-
 drivers/net/wireless/realtek/rtlwifi/base.h        |   4 +
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |  13 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |   8 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |  49 ++-
 drivers/net/wireless/realtek/rtlwifi/pci.h         |  10 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/dm.c    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.h    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.c   |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.h   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.h    |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.c   |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.h   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.h    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.c    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.h    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.c   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.h   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/dm.c    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |  40 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.h    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |   9 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |  49 ++-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.h   | 140 ++-----
 .../net/wireless/realtek/rtlwifi/rtl8192se/dm.c    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.h    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |   8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.c   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.h   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |  11 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.h    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.c   |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.h   |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/dm.c    |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |  13 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.h    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.h   |   3 +-
 .../realtek/rtlwifi/rtl8723com/fw_common.c         |   3 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |  15 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.h    |   2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |   6 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   |   5 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.h   |   3 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |  60 +--
 drivers/net/wireless/rsi/rsi_91x_core.c            |  33 +-
 drivers/net/wireless/rsi/rsi_91x_debugfs.c         |  19 +-
 drivers/net/wireless/rsi/rsi_91x_hal.c             |  86 ++--
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        | 446 ++++++++++++++++-=
----
 drivers/net/wireless/rsi/rsi_91x_main.c            |  34 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |  46 ++-
 drivers/net/wireless/rsi/rsi_91x_ps.c              |  15 +-
 drivers/net/wireless/rsi/rsi_91x_sdio.c            | 128 +++++-
 drivers/net/wireless/rsi/rsi_91x_usb.c             |   4 +-
 drivers/net/wireless/rsi/rsi_common.h              |   4 +-
 drivers/net/wireless/rsi/rsi_hal.h                 |   6 +-
 drivers/net/wireless/rsi/rsi_main.h                |  24 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                |  21 +-
 drivers/net/wireless/rsi/rsi_ps.h                  |   7 +-
 drivers/net/wireless/rsi/rsi_sdio.h                |   2 +
 150 files changed, 2639 insertions(+), 1911 deletions(-)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/acpi.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/acpi.h
