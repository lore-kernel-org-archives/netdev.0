From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2016-03-09
Date: Wed, 09 Mar 2016 22:06:40 +0200
Message-ID: <87vb4vpga7.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request for 4.6. I'm planning to send one more but I'm no=
t
sure if it will make it in time, we'll see.

Here notable changes are refactoring in bcma to create a common flash
driver, brcmfmac platform data improvements in include/linux and
beginning of AHB bus support for ath10k along with device tree binding
update. More info in the signed tag below.

Oh, and I just noticed that weirdly my name appeared in author field on
one of Janusz' ath9k patches. But I didn't consider this bad enough to
rebase everything so I let it be. Sorry Janusz :)

commit b9a9693fd9aea43f50b107dfc8cbaea317f95a79
Author: Kalle Valo <Janusz.Dziedzic-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Date:   Fri Nov 27 09:37:14 2015 +0100

    ath9k: request NOA update when chanctx active

Please let me know if you have any problems.

Kalle

The following changes since commit 00a1f0a93dea3cf1c141df79bfd06e7c9ee5=
4162:

  Merge branch 'reset_mac_header' (2016-03-04 22:45:14 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-03-09

for you to fetch changes up to 836856e3bd61d0644e5178a2c1b51d90459e2788=
:

  wireless: cw1200: use __maybe_unused to hide pm functions_ (2016-03-0=
8 12:32:52 +0200)

----------------------------------------------------------------
wireless-drivers patches for 4.6

Major changes:

ath10k

* dt: add bindings for ipq4019 wifi block
* start adding support for qca4019 chip

ath9k

* add device ID for Toshiba WLM-20U2/GN-1080
* allow more than one interface on DFS channels

bcma

* move flash detection code to ChipCommon core driver

brcmfmac

* IPv6 Neighbor discovery offload
* driver settings that can be populated from different sources
* country code setting in firmware
* length checks to validate firmware events
* new way to determine device memory size needed for BCM4366
* various offloads during Wake on Wireless LAN (WoWLAN)
* full Management Frame Protection (MFP) support

iwlwifi

* add support for thermal device / cooling device
* improvements in scheduled scan without profiles
* new firmware support (-21.ucode)
* add MSIX support for 9000 devices
* enable MU-MIMO and take care of firmware restart
* add support for large SKBs in mvm to reach A-MSDU
* add support for filtering frames from a BA session
* start implementing the new Rx path for 9000 devices
* enable the new Radio Resource Management (RRM) nl80211 feature flag
* add a new module paramater to disable VHT
* build infrastructure for Dynamic Queue Allocation

----------------------------------------------------------------
Alexander Tsoy (1):
      ath9k_htc: add device ID for Toshiba WLM-20U2/GN-1080

Alexey Khoroshilov (1):
      at76c50x-usb: avoid double usb_put_dev() after downloading intern=
al firmware in at76_probe()

Amitkumar Karwar (1):
      mwifiex: fix corner case association failure

Amitoj Kaur Chawla (1):
      mwifiex: Use to_delayed_work()

Andrei Otcheretianski (1):
      iwlwifi: add disable_11ac module param

Anilkumar Kolli (1):
      ath10k: reduce number of peers to support peer stats feature

Anthony Wong (1):
      rt2x00: add new rt2800usb device Buffalo WLI-UC-G450

Anton Protopopov (1):
      ath10k: fix erroneous return value

Arend van Spriel (1):
      brcmfmac: change function name for brcmf_cfg80211_wait_vif_event_=
timeout()

Arnd Bergmann (2):
      ath9k: reduce stack usage in ar9003_aic_cal_post_process
      wireless: cw1200: use __maybe_unused to hide pm functions_

Ashok Raj Nagarajan (2):
      ath10k: fix pktlog in QCA99X0
      ath10k: add hw_rev to trace events to support pktlog

Avri Altman (2):
      iwlwifi: mvm: forbid U-APSD for P2P Client if the firmware doesn'=
t support it
      iwlwifi: mvm: Send power command on BSS_CHANGED_BEACON_INFO if ne=
eded

Beni Lev (1):
      iwlwifi: mvm: Set global RRM capability

Bruno Randolf (3):
      rtl8xxxu: Enable monitor mode by handling filters
      rtl8xxxu: Document REG_RXFLTMAP registers
      rtl8xxxu: Enable data frame reception in rtl8xxxu_start

Chaya Rachel Ivgi (4):
      iwlwifi: mvm: add CT-KILL notification
      iwlwifi: mvm: add registration to thermal zone
      iwlwifi: mvm: add registration to cooling device
      iwlwifi: mvm: update ucode status before stopping device

Christian Lamparter (1):
      carl9170: import 1.9.9 firmware headers

Colin Ian King (2):
      rtlwifi: pass struct rtl_stats by reference as it is more efficie=
nt
      mt7601u: do not free dma_buf when ivp allocation fails

Dan Carpenter (1):
      mwifiex: fix an indenting mistake

Emmanuel Grumbach (15):
      Merge tag 'mac80211-next-for-davem-2016-02-26' into next2
      Merge tag 'iwlwifi-for-kalle-2016-02-15' into HEAD
      iwlwifi: mvm: bump firmware API to 21
      iwlwifi: pcie: aggregate Flow Handler configuration writes
      iwlwifi: pcie: fix identation in trans.c
      iwlwifi: mvm: send large SKBs to the transport
      iwlwifi: mvm: add Tx A-MSDU inside A-MPDU
      iwlwifi: mvm: allow to limit the A-MSDU from debugfs
      iwlwifi: mvm: don't enable A-MSDU when the rates are too low
      iwlwifi: mvm: don't send an A-MSDU that is larger than the TXF
      iwlwifi: pcie: prevent skbs shadowing in iwl_trans_pcie_reclaim
      iwlwifi: mvm: remove unused field in iwl_mvm_tid_data
      iwlwifi: mvm: various trivial cleanups
      iwlwifi: mvm: kill iwl_mvm_enable_agg_txq
      Merge branch 'fixes' into next

Eyal Shapira (1):
      iwlwifi: mvm: rs: fix a theoretical access to uninitialized array=
 elements

=46elix Fietkau (2):
      ath9k_hw: add low power tx gain table for AR953x
      ath9k: do not limit the number of DFS channel interfaces to 1

=46ranky Lin (3):
      brcmfmac: check for wowl support before enumerating feature flag
      brcmfmac: add neighbor discovery offload ip address table configu=
ration
      brcmfmac: check return for ARP ip setting iovar

Geert Uytterhoeven (1):
      ath9k: Drop useless const on chanctx_event_delta() return type

Golan Ben-Ami (1):
      iwlwifi: support ucode with d0 unified image - regular and usniff=
er

Haim Dreyfuss (1):
      iwlwifi: pcie: Add new configuration to enable MSIX

Hamad Kadmany (1):
      wil6210: TX vring optimization

Hante Meuleman (17):
      brcmfmac: Increase nr of supported flowrings.
      brcmfmac: Limit memory allocs to <64K
      brcmfmac: Configure country code using device specific settings
      brcmfmac: Add length checks on firmware events
      brcmfmac: use device memsize config from fw if defined
      brcmfmac: use bar1 window size as provided by pci subsystem
      brcmfmac: add support for the PCIE 4366c0 chip
      brcmfmac: remove pcie gen1 support
      brcmfmac: increase timeout for tx eapol
      brcmfmac: move module init and exit to common
      brcmfmac: add wowl gtk rekeying offload support
      brcmfmac: move platform data retrieval code to common
      brcmfmac: keep ARP and ND offload enabled during WOWL
      brcmfmac: switch to new platform data
      brcmfmac: merge platform data and module paramaters
      brcmfmac: integrate add_keyext in add_key
      brcmfmac: add 802.11w management frame protection support

Jakub Sitnicki (1):
      rtl8xxxu: Use REG_EFUSE_TEST register only on multifunctional dev=
ices

Jes Sorensen (22):
      rtl8xxxu: Minor cleanup to rtl8xxxu_download_firmware()
      rtl8xxxu: rtl8xxxu_download_firmware(): Cosmetic cleanups
      rtl8xxxu: If fw running in RAM, reset the 8051 before trying to d=
ownload a new one
      rtl8xxxu: Add RQPN_[NE]PQ_SHIFT values
      rtl8xxxu: Define SYS_CFG_SW_OFFLOAD_EN
      rtl8xxxu: Add REG_TX_REPORT_* defines
      rtl8xxxu: Add more RCR bits
      rtl8xxxu: Implement rtl8xxxu_reset_8051()
      rtl8xxxu: Add definitions for antenna selection registers for 872=
3BU
      rtl8xxxu: Add mbox extension register definitions for 8723B
      rtl8xxxu: Add REG_OFDM0_RX_D_SYNC_PATH definitions
      rtl8xxxu: Remove unused clutter for handling recursive calls to r=
tl8xxxu_init_device()
      rtl8xxxu: Fix cosmetics to quiet down checkpatch police
      rtl8xxxu: Remove duplicate USB ID
      rtl8xxxu: Fix 80 character per line issue
      rtl8xxxu: rtl8xxxu_set_linktype(): Be consistent aboutregister si=
ze REG_MSR
      rtl8xxxu: Set correct bit to reset MCU IO wrapper
      rtl8xxxu: Remove unused mgmt variable from rtl8xxxu_rx_complete()
      rtl8xxxu: Remove unused len/cnt variables from rtl8xxxu_rx_comple=
te()
      rtl8xxxu: Do not mask RF registers to 6 bits
      rtl8xxxu: Make device_init kludge 8723au only
      rtl8xxxu: Add missing bit define for REG_APS_FSMCO

Kalle Valo (4):
      ath9k: request NOA update when chanctx active
      Merge ath-next from ath.git
      Merge 'net-next/master'
      Merge tag 'iwlwifi-next-for-kalle-2016-03-02' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next

Larry Finger (7):
      rtlwifi: Prepare for reworking 5G channels
      rtlwifi: rtl8192de: Convert driver to use common 5G channels
      rtlwifi: rtl8192ee: Convert driver to use new 5G channel tables
      rtlwifi: rtl8821ae: Convert driver to use common 5G channel table
      rtlwifi: rtl8821ae: Silence useless log output
      rtlwifi: Change long delays to sleeps
      rtlwifi: Fix size of wireless mode variable

Lars-Peter Clausen (2):
      b43: Remove unnecessary synchronize_irq() before free_irq()
      rtlwifi: Remove unnecessary synchronize_irq() before free_irq()

Liad Kaufman (2):
      iwlwifi: mvm: disable DQA support
      iwlwifi: mvm: support sw queue start/stop from mvm

Lior David (2):
      wil6210: fix privacy flag calculation in change_beacon
      wil6210: use extra IEs from probe response

Luca Coelho (4):
      iwlwifi: mvm: handle pass all scan reporting
      iwlwifi: pcie: add pm_prepare and pm_complete ops
      iwlwifi: mvm: only release the trans ref if d0i3 is supported in =
fw
      iwlwifi: mvm: take the transport ref back when leaving

Matti Gottlieb (1):
      iwlwifi: mvm: Disable beacon storing in  D3 when WOWLAN configure=
d

Maya Erez (5):
      wil6210: handle tx completions only if vring tx data is enabled
      wil6210: find TX vring only if vring_tx_data is enabled
      wil6210: handle multiple connect/disconnect events
      wil6210: prevent access to vring_tx_data lock during its init
      wil6210: protect synchronous wmi commands handling

Miaoqing Pan (7):
      ath9k: avoid ANI restart if no trigger
      ath9k: clean up ANI per-channel pointer checking
      ath9k: do not reset while BB panic(0x4000409) on ar9561
      ath9k: fix inconsistent use of tab and space in indentation
      ath9k: fix data bus error on ar9300 and ar9580
      ath9k: make NF load complete quickly and reliably
      ath9k: clear bb filter calibration power threshold

Michal Kazior (6):
      ath10k: prevent txrx running for too long
      ath10k: rename some HTT events
      ath10k: add new htt definitions
      ath10k: add new FW_FEATURE_PEER_FLOW_CONTROL
      ath10k: clean up cont frag desc init code
      ath10k: implement basic support for new tx path firmware

Mohammed Shafi Shajakhan (10):
      ath10k: add support for parsing per STA rx_duration for 10.2.4
      ath10k: fix naming Peer stats rssi_changed field in 10.2.4
      ath10k: cleanup setting pdev paramaters
      ath10k: rename few function names of firmware stats
      ath10k: provision to support periodic peer stats update
      ath10k: enable periodic peer stats update
      ath10k: add debugfs support for Per STA total rx duration
      ath10k: fix updating peer stats rx duration
      ath10k: fix pointless update of peer stats list
      ath10k: fix sanity check on enabling btcoex via debugfs

One Thousand Gnomes (1):
      rt2x00: unterminated strlen of user data

Peter Oh (4):
      ath10k: rename Mesh related service names
      ath10k: update 10.4 WMI service map
      ath10k: use vif->type and vif->p2p for P2P_GO check
      ath10k: add abstraction layer for vdev subtype

Rafa=C5=82 Mi=C5=82ecki (3):
      bcma: drop unneeded fields from bcma_pflash struct
      bcma: move parallel flash support to separated file
      bcma: move flash detection code to ChipCommon core driver

Raja Mani (15):
      dt: bindings: add bindings for ipq4019 wifi block
      ath10k: make some of ath10k_pci_* func reusable
      ath10k: make ath10k_pci_read32/write32() ops more generic
      ath10k: pull reusable code from pci probe and remove for ahb
      ath10k: add basic skeleton to support ahb
      ath10k: include qca4019 register map table
      ath10k: add helper functions in ahb.c for reg rd/wr
      ath10k: add clock ctrl related functions in ahb
      ath10k: add reset ctrl related functions in ahb
      ath10k: add chip and bus halt logic in ahb
      ath10k: include irq related functions in ahb
      ath10k: add resource init and deinit in ahb
      ath10k: expose hif ops for ahb
      ath10k: add qca4019 hw params
      ath10k: populate qca4019 fw specific wmi init params

Rajkumar Manoharan (2):
      ath10k: reduce rx_lock contention for htt rx indication
      ath10k: process htt rx indication as batch mode

Sara Sharon (13):
      iwlwifi: mvm: set the correct descriptor size for tracing
      iwlwifi: mvm: fix RSS key sizing
      iwlwifi: mvm: enable VHT MU-MIMO for supported hardware
      iwlwifi: mvm: update firmware of VHT MU-MIMO groups status on res=
tart
      iwlwifi: support tracing wide commands
      iwlwifi: mvm: update rx_status with mactime flag
      iwlwifi: mvm: support filtered frames notification
      iwlwifi: pcie: configure more RFH settings
      iwlwifi: mvm: add duplicate packet detection per rx queue
      iwlwifi: mvm: add RSS queues notification infrastructure
      iwlwifi: mvm: support VHT MU-MIMO notification
      iwlwifi: mvm: take care of padded packets
      iwlwifi: pcie: detect and workaround invalid write ptr behavior

Sudip Mukherjee (1):
      ath10k: remove impossible code

Tobias Klauser (2):
      rtl8xxxu: Fix typo in Kconfig help text
      rtl8xxxu: Check return value of kmemdup()

Ujjal Roy (3):
      mwifiex: Fixed incorrect indentation issue
      mwifiex: Removed extra spaces before commas
      mwifiex: Added missing spaces around brackets

Vladimir Kondratiev (1):
      wil6210: wait for disconnect completion

Xinming Hu (3):
      mwifiex: add delay when tdls confirm frame is queued
      mwifiex: add sdio multiport aggregation debug information
      mwifiex: do not set multiport flag for tx/rx single packet

Yanbo Li (1):
      ath10k: remove the p2p notice of absence info from 10.2.4 FW beac=
on info

 .../bindings/net/wireless/qcom,ath10k.txt          |   89 +-
 drivers/bcma/Kconfig                               |    5 +
 drivers/bcma/Makefile                              |    1 +
 drivers/bcma/bcma_private.h                        |   18 +-
 drivers/bcma/driver_chipcommon.c                   |   30 +
 drivers/bcma/driver_chipcommon_pflash.c            |   49 +
 drivers/bcma/driver_mips.c                         |   63 +-
 drivers/bcma/main.c                                |    2 +-
 drivers/net/wireless/ath/ath10k/Kconfig            |    6 +
 drivers/net/wireless/ath/ath10k/Makefile           |    2 +
 drivers/net/wireless/ath/ath10k/ahb.c              |  933 ++++++++++++=
++++++++
 drivers/net/wireless/ath/ath10k/ahb.h              |   87 ++
 drivers/net/wireless/ath/ath10k/core.c             |   48 +-
 drivers/net/wireless/ath/ath10k/core.h             |   20 +
 drivers/net/wireless/ath/ath10k/debug.c            |   46 +-
 drivers/net/wireless/ath/ath10k/debug.h            |    7 +
 drivers/net/wireless/ath/ath10k/debugfs_sta.c      |   41 +
 drivers/net/wireless/ath/ath10k/htt.c              |    8 +-
 drivers/net/wireless/ath/ath10k/htt.h              |  169 +++-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   54 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |  146 ++-
 drivers/net/wireless/ath/ath10k/hw.c               |   39 +
 drivers/net/wireless/ath/ath10k/hw.h               |   24 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   57 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  171 ++--
 drivers/net/wireless/ath/ath10k/pci.h              |   49 +
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    3 +
 drivers/net/wireless/ath/ath10k/trace.h            |   15 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   11 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |    1 +
 drivers/net/wireless/ath/ath10k/wmi.c              |  162 +++-
 drivers/net/wireless/ath/ath10k/wmi.h              |   92 +-
 drivers/net/wireless/ath/ath9k/ani.c               |   36 +-
 drivers/net/wireless/ath/ath9k/ar9003_aic.c        |   79 +-
 drivers/net/wireless/ath/ath9k/ar9003_aic.h        |    1 -
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    3 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   12 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    3 +
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   |   65 ++
 drivers/net/wireless/ath/ath9k/calib.c             |   38 +-
 drivers/net/wireless/ath/ath9k/channel.c           |    4 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                |   10 +
 drivers/net/wireless/ath/ath9k/init.c              |   25 +-
 drivers/net/wireless/ath/ath9k/main.c              |    5 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    4 +-
 drivers/net/wireless/ath/carl9170/fwcmd.h          |    8 +
 drivers/net/wireless/ath/carl9170/fwdesc.h         |    6 +
 drivers/net/wireless/ath/carl9170/hw.h             |   73 +-
 drivers/net/wireless/ath/carl9170/version.h        |    6 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  162 +++-
 drivers/net/wireless/ath/wil6210/debugfs.c         |    6 +-
 drivers/net/wireless/ath/wil6210/main.c            |  112 +--
 drivers/net/wireless/ath/wil6210/netdev.c          |    5 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   46 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   11 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  174 +++-
 drivers/net/wireless/atmel/at76c50x-usb.c          |    2 -
 drivers/net/wireless/broadcom/b43/main.c           |    6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |  105 +--
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |    4 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  617 ++++++++----=
-
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |   20 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |  152 +++-
 .../wireless/broadcom/brcm80211/brcmfmac/common.h  |   43 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  180 +++-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    9 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |   14 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.h |   10 +-
 .../broadcom/brcm80211/brcmfmac/flowring.c         |   38 +-
 .../broadcom/brcm80211/brcmfmac/flowring.h         |   20 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |   57 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.h    |   68 +-
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |   29 +-
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |   11 +-
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.h  |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/of.c  |   22 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/of.h  |    4 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   26 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |  206 ++---
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  103 ++-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.h    |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |   16 +-
 .../broadcom/brcm80211/include/brcmu_wifi.h        |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |   49 +
 .../wireless/intel/iwlwifi/iwl-devtrace-iwlwifi.h  |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |    7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |   24 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   10 +
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |   24 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   52 ++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |  126 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |   32 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |    2 +
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   84 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  109 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   94 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   25 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |   63 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  146 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   36 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   34 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   23 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |  461 +++++++++-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  195 +++-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   41 +
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  100 ++-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |  206 ++++-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  277 ++++--
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   10 +-
 drivers/net/wireless/marvell/mwifiex/11h.c         |    6 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |    2 +-
 drivers/net/wireless/marvell/mwifiex/ioctl.h       |    6 +
 drivers/net/wireless/marvell/mwifiex/main.h        |    5 +
 drivers/net/wireless/marvell/mwifiex/pcie.c        |    4 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   16 +
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |    1 +
 drivers/net/wireless/marvell/mwifiex/tdls.c        |    7 +
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |    2 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |    4 +-
 drivers/net/wireless/marvell/mwifiex/util.c        |   20 +
 drivers/net/wireless/mediatek/mt7601u/mcu.c        |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c     |    1 +
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.c   |    5 +-
 drivers/net/wireless/realtek/rtl8xxxu/Kconfig      |    2 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   |  183 ++--
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |    2 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   55 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |   60 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |    3 +-
 drivers/net/wireless/realtek/rtlwifi/rc.c          |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |   23 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   12 -
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.h   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   20 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |   27 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.h   |    2 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |   22 +-
 drivers/net/wireless/st/cw1200/cw1200_spi.c        |    9 +-
 drivers/net/wireless/st/cw1200/pm.h                |    9 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |   11 +-
 include/linux/platform_data/brcmfmac-sdio.h        |  135 ---
 include/linux/platform_data/brcmfmac.h             |  185 ++++
 162 files changed, 6439 insertions(+), 1820 deletions(-)
 create mode 100644 drivers/bcma/driver_chipcommon_pflash.c
 create mode 100644 drivers/net/wireless/ath/ath10k/ahb.c
 create mode 100644 drivers/net/wireless/ath/ath10k/ahb.h
 delete mode 100644 include/linux/platform_data/brcmfmac-sdio.h
 create mode 100644 include/linux/platform_data/brcmfmac.h
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
