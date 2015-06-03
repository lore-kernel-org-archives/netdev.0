From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-06-03
Date: Wed, 03 Jun 2015 23:07:47 +0300
Message-ID: <87bngwtv1o.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59536 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818AbbFCUH6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 16:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request for 4.2. Most notable change here is a new driver
mt7601u for a Mediatek USB Wi-Fi device, for other driver more
information in the signed tag. There's a trivial conflict in iwlwifi
Kconfig help text but otherwise I'm not expecting any issues. But pleas=
e
let me know if you have any problems.

Kalle

The following changes since commit 01b6961410b76af228eb993220024ff6db6b=
a80c:

  cxgb4: Add PHY firmware support for T420-BT cards (2015-05-25 00:17:2=
4 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-06-03

for you to fetch changes up to 1690faef645ea8725fafdfe6451cf7828a676ad8=
:

  Merge tag 'iwlwifi-next-for-kalle-2015-06-03' of https://git.kernel.o=
rg/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2015-06-03 12:15:51 +=
0300)

----------------------------------------------------------------

new driver mt7601u for MediaTek Wi-Fi devices MT7601U

ath10k:

* qca6174 power consumption improvements, enable ASPM etc (Michal)

wil6210:

* support Wi-Fi Simple Configuration in STA mode

iwlwifi:

* a few fixes (re-enablement of interrupts for certain new
  platforms that have special power states)
* Rework completely the RBD allocation model towards new
  multi RX hardware.
* cleanups
* scan reworks continuation (Luca)

mwifiex:

* improve firmware debug functionality

rtlwifi:

* update regulatory database

brcmfmac:

* cleanup and new feature support in PCIe code
* alternative nvram loading for router support

----------------------------------------------------------------
Amitkumar Karwar (6):
      mwifiex: fix SDIO firmware dump problem
      mwifiex: fix a possible double free issue
      mwifiex: dump driver information for PCIe interface
      mwifiex: minor changes in debug messages
      mwifiex: use generic name 'device dump'
      mwifiex: device dump support via devcoredump framework

Andrei Otcheretianski (1):
      iwlwifi: mvm: Configure agg. queue before assigning it to STA

Arend van Spriel (2):
      brcmfmac: allow device tree node without 'interrupts' property
      brcmfmac: fix invalid access to struct acpi_device fields

Arik Nemtsov (1):
      iwlwifi: mvm: clean interfaces on drv_stop

Arnd Bergmann (1):
      brcmfmac: avoid gcc-5.1 warning

Avinash Patil (1):
      mwifiex: reduce severity of debug messages for mgmt rx

Avraham Stern (3):
      iwlwifi: mvm: print scanned channel list on scan iteration comple=
te notification
      iwlwifi: mvm: add UMAC scan iteration complete notification
      iwlwifi: mvm: add support for 8 level scan priority API

Avri Altman (2):
      iwlwifi: pcie: Remove redundant check for family type
      iwlwifi: pcie: Control access to the NIC's PM registers via iwl_c=
fg

Chin-ran Lo (1):
      mwifiex: add support for FW memory read/write operations

Dan Carpenter (2):
      ath9k_htc: memory corruption calling set_bit()
      rndis_wlan: harmless issue calling set_bit()

Daniel Drake (1):
      rtlwifi: btcoexist: Fix interference between rtl8723be and Blueto=
oth

David Spinadel (2):
      iwlwifi: mvm: add inactive state to ebs status
      iwlwifi: mvm: don't use EBS for P2P find

Eliad Peller (3):
      iwlwifi: mvm: fix ROC reference accounting
      iwlwifi: tracing: add rx cmd header fields
      iwlwifi: pcie: re-enable interrupts on resume

Emmanuel Grumbach (9):
      Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-=
next
      iwlwifi: bump API to 14
      iwlwifi: pcie: simplify return value
      iwlwifi: mvm: BT Coex - remove useless code
      iwlwifi: mvm: BT Coex - allocate a short command on the stack
      iwlwifi: mvm: BT Coex - fix shared antenna check with new API
      Merge tag 'mac80211-next-for-davem-2015-05-06' into iwlwifi-next
      iwlwifi: mvm: implement the BlockAck related debug triggers
      iwlwifi: bump the iwlmvm API number to 15

Eran Harary (1):
      iwlwifi: 8000: fallback to default NVM file

Eyal Shapira (1):
      iwlwifi: mvm: rs: pass rate directly to column checks

=46ranky Lin (3):
      brcmfmac: remove pci shared structure rev4 support
      brcmfmac: remove dummy cache flush/invalidate function
      brcmfmac: add support for dma indices feature

=46u, Zhonghui (1):
      brcmfmac: prohibit ACPI power management for brcmfmac driver

Hante Meuleman (1):
      brcmfmac: Improve throughput by scheduling msbug flow worker.

Hauke Mehrtens (1):
      bcma: add module_bcma_driver()

Ido Yariv (1):
      iwlwifi: update thermal throttling values for 8000 devices

Jakub Kicinski (1):
      add mt7601u driver

Janusz Dziedzic (2):
      ath10k: enable ASPM
      ath10k: fix idle power consumption

Johannes Berg (8):
      iwlwifi: refactor common transport alloc/init code
      iwlwifi: mvm: advertise randomised netdetect MAC address
      iwlwifi: mvm: handle device start failure correctly
      iwlwifi: mvm: enable IEEE80211_HW_SUPPORT_FAST_XMIT
      iwlwifi: dvm: enable IEEE80211_HW_SUPPORT_FAST_XMIT
      iwlwifi: mvm: simplify iwl_mvm_stop_roc()
      iwlwifi: prepare for higher API/CAPA bits
      iwlwifi: mvm: advertise only HW-supported ciphers

Kalle Valo (3):
      ath10k: add ATH10K_FW_FEATURE_IGNORE_OTP_RESULT
      Merge ath-next from ath.git
      Merge tag 'iwlwifi-next-for-kalle-2015-06-03' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next

Kevin Lo (1):
      rtlwifi: fix typos in Kconfig

Lauri Kentt=C3=A4 (1):
      rtlwifi: rtl8188ee: Fix pwrseqcmd.h include path.

Liad Kaufman (1):
      iwlwifi: wrt: add mipi type to debug types

Luciano Coelho (16):
      iwlwifi: pcie: don't call set_pwr functions for family 8000
      iwlwifi: mvm: small fix in a comment about UMAC scan schedules
      iwlwifi: mvm: remove the UMAC specific scan types
      iwlwifi: mvm: fix the net-detect SSIDs report order
      iwlwifi: mvm: make iwl_mvm_config_sched_scan_profiles() static
      iwlwifi: mvm: reorganize scan stopping functions
      iwlwifi: mvm: don't stop regular scans when going out of idle sta=
te
      iwlwifi: mvm: combine part of the scan stop flows
      iwlwifi: mvm: rename umac scan stop function
      iwlwifi: mvm: rename some LMAC-specific scan functions
      iwlwifi: mvm: refactor UMAC scan UID handling
      iwlwifi: mvm: remove code that stops multiple UMAC scans of a typ=
e
      iwlwifi: mvm: combine UMAC and LMAC scan_stop functions
      iwlwifi: mvm: combine regular and sched scan stop functions
      iwlwifi: mvm: make UMAC scans use the stopping scan status
      iwlwifi: mvm: treat scan races also on UMAC scans

Matti Gottlieb (3):
      iwlwifi: mvm: Add debugfs entry for Tx power limit
      iwlwifi: mvm: Remove old scan commands
      iwlwifi: mvm: Add DC2DC_CONFIG_CMD (0x83) cmd & TLV

Michal Kazior (2):
      ath10k: enable pci soc powersaving
      ath10k: add new 4addr related fw_feature

Nicholas Krause (1):
      iwlwifi: Remove use of the deprecacted PTR_RET

Nicholas Mc Guire (1):
      carl9170: match wait_for_completion_timeout return type

Okash Khawaja (2):
      adm8211: fix checkpatch errors for indentation and new line
      adm8211: fixed the possible pci cache line sizes inside switch-ca=
se

Oleksij Rempel (1):
      ath9k: split ar5008_hw_spur_mitigate and reuse common code in ar9=
002_hw_spur_mitigate.

Peter Oh (1):
      ath10k: increase relay buffer size of spectral scan

Rafa=C5=82 Mi=C5=82ecki (4):
      brcmfmac: simplify check stripping v2 NVRAM
      brcmfmac: simplify check finding NVRAM v1 device path
      brcmfmac: treat \0 as end of comment when parsing NVRAM
      brcmfmac: allow NVRAM values to contain spaces

Sara Sharon (1):
      iwlwifi: pcie: New RBD allocation model

Shailendra Verma (1):
      ray_cs: Change 1 to true for bool type variable.

Shao Fu (5):
      rtlwifi: Update regulatory database
      rtlwifi: rtl8188ee: Apply the new regulatory information
      rtlwifi: rtl8192ee: Apply the regulatory changes to driver
      rtlwifi: rtl8723be: Update driver for regulatory changes
      rtlwifi: rtl8821ae: Fix problem with regulatory information

Taehee Yoo (2):
      rtlwifi: rtl8192cu: Remove setting REG_BCN_MAX_ERR code in _rtl92=
cu_set_media_status().
      rtlwifi: rtl8192cu: Remove rtl92c_init_beacon_max_error's paramet=
er

Vasanthakumar Thiagarajan (1):
      ath10k: fix survey information reporting

Vincent Fann (1):
      rtlwifi: Remove the clear interrupt routine from all drivers

Vladimir Kondratiev (13):
      wil6210: fw debug mode
      wil6210: debug [add|del]_key operations
      wil6210: trace disconnect source
      wil6210: stop_ap to leave interface closed
      wil6210: update FW file name
      wil6210: increase timeout for the "echo" command
      wil6210: update Rx descriptor fields
      wil6210: fix boot loader "ready" indication
      wil6210: fix for probe_resp IE's
      wil6210: Add pmc debug mechanism memory management
      wil6210: broadcast for secure link
      wil6210: support WSC for STA mode
      wil6210: fix format specifier for dma_addr_t

Zhaoyang Liu (3):
      mwifiex: add prints debug ctrl support
      mwifiex: add dump data debug support
      mwifiex: change dbg print func to mwifiex_dbg

 MAINTAINERS                                        |    6 +
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/Makefile                      |    2 +
 drivers/net/wireless/adm8211.c                     |   20 +-
 drivers/net/wireless/ath/ath10k/core.c             |    4 +-
 drivers/net/wireless/ath/ath10k/core.h             |    8 +
 drivers/net/wireless/ath/ath10k/debug.h            |    1 +
 drivers/net/wireless/ath/ath10k/htt_rx.c           |   14 +-
 drivers/net/wireless/ath/ath10k/mac.c              |    9 +-
 drivers/net/wireless/ath/ath10k/pci.c              |  317 +++--
 drivers/net/wireless/ath/ath10k/pci.h              |   95 +-
 drivers/net/wireless/ath/ath10k/spectral.c         |    5 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |    4 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |  155 +--
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |  144 +--
 drivers/net/wireless/ath/ath9k/htc.h               |    6 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    2 +
 drivers/net/wireless/ath/carl9170/usb.c            |    5 +-
 drivers/net/wireless/ath/wil6210/Makefile          |    1 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  128 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |  107 +-
 drivers/net/wireless/ath/wil6210/main.c            |   29 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    5 +
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    6 -
 drivers/net/wireless/ath/wil6210/pmc.c             |  375 ++++++
 drivers/net/wireless/ath/wil6210/pmc.h             |   27 +
 drivers/net/wireless/ath/wil6210/txrx.c            |   48 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |   24 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   24 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   70 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   40 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   18 +
 .../net/wireless/brcm80211/brcmfmac/commonring.c   |   18 -
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |   56 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/flowring.h |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   20 +-
 drivers/net/wireless/brcm80211/brcmfmac/of.c       |   11 +-
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |  157 ++-
 drivers/net/wireless/iwlwifi/Kconfig               |    1 +
 drivers/net/wireless/iwlwifi/Makefile              |    1 +
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    1 +
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   18 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   71 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |    1 +
 .../net/wireless/iwlwifi/iwl-devtrace-iwlwifi.h    |   15 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   32 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |    5 +
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h    |    3 +
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    6 -
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |    6 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   99 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   24 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   30 +-
 drivers/net/wireless/iwlwifi/iwl-trans.c           |  113 ++
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   22 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  103 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c     |    2 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   37 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |   21 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   14 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |   35 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   56 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |    8 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  265 ++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   59 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   16 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   34 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   27 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  550 ++++-----
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   14 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   33 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   35 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |    2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   17 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   51 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  415 +++++--
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   64 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |    2 -
 drivers/net/wireless/mediatek/Kconfig              |   10 +
 drivers/net/wireless/mediatek/Makefile             |    1 +
 drivers/net/wireless/mediatek/mt7601u/Kconfig      |    6 +
 drivers/net/wireless/mediatek/mt7601u/Makefile     |    9 +
 drivers/net/wireless/mediatek/mt7601u/core.c       |   78 ++
 drivers/net/wireless/mediatek/mt7601u/debugfs.c    |  172 +++
 drivers/net/wireless/mediatek/mt7601u/dma.c        |  533 +++++++++
 drivers/net/wireless/mediatek/mt7601u/dma.h        |  127 ++
 drivers/net/wireless/mediatek/mt7601u/eeprom.c     |  414 +++++++
 drivers/net/wireless/mediatek/mt7601u/eeprom.h     |  151 +++
 drivers/net/wireless/mediatek/mt7601u/init.c       |  625 ++++++++++
 drivers/net/wireless/mediatek/mt7601u/initvals.h   |  164 +++
 .../net/wireless/mediatek/mt7601u/initvals_phy.h   |  291 +++++
 drivers/net/wireless/mediatek/mt7601u/mac.c        |  569 +++++++++
 drivers/net/wireless/mediatek/mt7601u/mac.h        |  178 +++
 drivers/net/wireless/mediatek/mt7601u/main.c       |  412 +++++++
 drivers/net/wireless/mediatek/mt7601u/mcu.c        |  534 +++++++++
 drivers/net/wireless/mediatek/mt7601u/mcu.h        |   94 ++
 drivers/net/wireless/mediatek/mt7601u/mt7601u.h    |  390 ++++++
 drivers/net/wireless/mediatek/mt7601u/phy.c        | 1251 ++++++++++++=
++++++++
 drivers/net/wireless/mediatek/mt7601u/regs.h       |  636 ++++++++++
 drivers/net/wireless/mediatek/mt7601u/trace.c      |   21 +
 drivers/net/wireless/mediatek/mt7601u/trace.h      |  400 +++++++
 drivers/net/wireless/mediatek/mt7601u/tx.c         |  319 +++++
 drivers/net/wireless/mediatek/mt7601u/usb.c        |  360 ++++++
 drivers/net/wireless/mediatek/mt7601u/usb.h        |   77 ++
 drivers/net/wireless/mediatek/mt7601u/util.c       |   42 +
 drivers/net/wireless/mediatek/mt7601u/util.h       |   77 ++
 drivers/net/wireless/mwifiex/11h.c                 |   48 +-
 drivers/net/wireless/mwifiex/11n.c                 |   24 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |    7 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   51 +-
 drivers/net/wireless/mwifiex/Kconfig               |    2 +
 drivers/net/wireless/mwifiex/README                |    6 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  462 ++++----
 drivers/net/wireless/mwifiex/cfp.c                 |   50 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |  365 +++---
 drivers/net/wireless/mwifiex/debugfs.c             |  165 ++-
 drivers/net/wireless/mwifiex/ethtool.c             |   97 --
 drivers/net/wireless/mwifiex/fw.h                  |    9 +
 drivers/net/wireless/mwifiex/init.c                |   54 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    6 +
 drivers/net/wireless/mwifiex/join.c                |  208 ++--
 drivers/net/wireless/mwifiex/main.c                |  213 +++-
 drivers/net/wireless/mwifiex/main.h                |   59 +-
 drivers/net/wireless/mwifiex/pcie.c                |  589 ++++-----
 drivers/net/wireless/mwifiex/scan.c                |  377 +++---
 drivers/net/wireless/mwifiex/sdio.c                |  458 ++++---
 drivers/net/wireless/mwifiex/sta_cmd.c             |  159 ++-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |  197 +--
 drivers/net/wireless/mwifiex/sta_event.c           |  130 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  145 ++-
 drivers/net/wireless/mwifiex/sta_rx.c              |   13 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |   18 +-
 drivers/net/wireless/mwifiex/tdls.c                |   86 +-
 drivers/net/wireless/mwifiex/txrx.c                |   30 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   20 +-
 drivers/net/wireless/mwifiex/uap_event.c           |   44 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   36 +-
 drivers/net/wireless/mwifiex/usb.c                 |  141 ++-
 drivers/net/wireless/mwifiex/util.c                |   27 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   98 +-
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    6 +-
 drivers/net/wireless/rtlwifi/Kconfig               |    2 +-
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.c   |    7 +-
 drivers/net/wireless/rtlwifi/regd.c                |   42 +-
 drivers/net/wireless/rtlwifi/regd.h                |    1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   20 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c        |   21 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   13 -
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |   21 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |   24 +-
 include/linux/bcma/bcma.h                          |    9 +
 160 files changed, 13389 insertions(+), 3410 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wil6210/pmc.c
 create mode 100644 drivers/net/wireless/ath/wil6210/pmc.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-trans.c
 create mode 100644 drivers/net/wireless/mediatek/Kconfig
 create mode 100644 drivers/net/wireless/mediatek/Makefile
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/Kconfig
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/Makefile
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/core.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/debugfs.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/dma.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/dma.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/eeprom.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/eeprom.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/init.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/initvals.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/initvals_phy.=
h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/mac.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/mac.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/main.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/mcu.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/mcu.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/mt7601u.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/phy.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/regs.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/trace.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/trace.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/tx.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/usb.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/usb.h
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/util.c
 create mode 100644 drivers/net/wireless/mediatek/mt7601u/util.h

--=20
Kalle Valo
