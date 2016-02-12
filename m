From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2016-02-12
Date: Fri, 12 Feb 2016 16:40:23 +0200
Message-ID: <87fuwyt2js.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44916 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbcBLOk3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 09:40:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's first pull request for 4.6. We have a new kconfig option
CONFIG_IWLWIFI_PCIE_RTPM for iwlwifi runtime power management. wl12xxx
got device tree support for the spi bus and added a bindings document
for it. More info in the tag below.

Please let me know if you have any problems.

Kalle

The following changes since commit 7a26019fdecdb45ff784ae4e3b7e0cc90451=
00ca:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
1-15 18:36:23 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-02-12

for you to fetch changes up to 11e70824e75f2cfbad9ae066ca5b29e1c361f19e=
:

  mwifiex: firmware dump support for w8997 chipset (2016-02-07 09:15:44=
 +0200)

----------------------------------------------------------------
Major changes:

wl12xx

* add device tree support for SPI

mwifiex

* add debugfs file to read chip information
* add MSIx support for newer pcie chipsets (8997 onwards)
* add schedule scan support
* add WoWLAN net-detect support
* firmware dump support for w8997 chipset

iwlwifi

* continue the work on multiple Rx queues
* add support for beacon storing used in low power states
* use the regular firmware image of WoWLAN
* fix 8000 devices for Big Endian machines
* more firmware debug hooks
* add support for P2P Client snoozing
* make the beacon filtering for AP mode configurable
* fix transmit queues overflow with LSO

libertas

* add support for setting power save via cfg80211

----------------------------------------------------------------
Amitkumar Karwar (2):
      mwifiex: use SYNC flag for canceling host sleep
      mwifiex: increase the priority of firmware dump message

Andreas Kemnade (6):
      libertas: fix pointer bugs for PS_MODE commands
      libertas: check whether bus can do more than polling
      libertas: do not confirm sleep if commands are pending
      libertas: go back to ps mode without commands pending
      libertas: fix ps-mode related removal problems
      libertas: add an cfg80211 interface for powersaving

Andrei Otcheretianski (1):
      iwlwifi: mvm: allow to disable beacon filtering for AP/GO interfa=
ce

Andrzej Hajda (1):
      wlcore: fix error handling in wlcore_event_fw_logger

Arnd Bergmann (1):
      hostap: avoid uninitialized variable use in hfa384x_get_rid

Avri Altman (3):
      iwlwifi: mvm: Add P2P client snoozing
      iwlwifi: mvm: Remove bf_vif from iwl_power_vifs
      iwlwifi: mvm: Remove iwl_mvm_update_beacon_abort

Chaya Rachel Ivgi (1):
      iwlwifi: mvm: add support for negative temperatures

Dan Carpenter (1):
      mwifiex: fix a reversed condition

Emmanuel Grumbach (2):
      iwlwifi: pcie: buffer packets to avoid overflowing Tx queues
      iwlwifi: various comments and code cleanups

Ganapathi Bhat (1):
      mwifiex: add RSSI support for net-detect

Golan Ben-Ami (2):
      iwlwifi: mvm: add trigger for firmware dump upon TX response stat=
us
      iwlwifi: mvm: make collecting fw debug data optional

Gregory Greenman (1):
      iwlwifi: mvm: rs: fix TPC action decision algorithm

Hubert Tarasiuk (1):
      iwlwifi: dvm: handle zero brightness for wifi LED

Johannes Berg (5):
      iwlwifi: mvm: remove shadowing variable
      iwlwifi: mvm: fix debugfs signedness warning
      iwlwifi: mvm: track low-latency sources separately
      iwlwifi: mvm: support setting minimum quota from debugfs
      iwlwifi: treat iwl_parse_nvm_data() MAC addr as little endian

Kalle Valo (1):
      Merge tag 'iwlwifi-next-for-kalle-2016-01-31_2' of https://git.ke=
rnel.org/.../iwlwifi/iwlwifi-next

Luca Coelho (1):
      iwlwifi: pcie: add initial RTPM support for PCI

Luciano Coelho (1):
      iwlwifi: pcie: add RTPM support when wifi is enabled

Matti Gottlieb (1):
      iwlwifi: mvm: Do not switch to D3 image on suspend

Max Stepanov (1):
      iwlwifi: mvm: add debug print if scan config is ignored

Nachiket Kukade (1):
      mwifiex: fix bandwidth display problem

Paul Mcquade (3):
      net: wireless: rt2x00: Fixed Spacing issues
      net: wireless: rt2x00: Space issue
      net: wireless: rt2x00: Space Required

Rafa=C5=82 Mi=C5=82ecki (15):
      bcma: support identifying MX25L25635F serial flash
      bcma: identify bus cores (devices) found on BCM47189
      bcma: support chipsets with PMU and GCI cores (devices)
      bcma: use _PMU_ in all names of PMU registers
      bcma: support PMU present as separated bus core
      brcmfmac: fix setting primary channel for 80 MHz width
      bcma: init serial console directly from ChipCommon code
      bcma: add support for BCM47094
      bcma: claim only 14e4:4365 PCI Dell card with SoftMAC BCM43142
      brcmfmac: analyze descriptors of current component only
      brcmfmac: allow storing PMU core without wrapper address
      brcmfmac: read extended capabilities of ChipCommon core
      brcmfmac: access PMU registers using standalone PMU core if avail=
able
      brcmfmac: add support for 14e4:4365 PCI ID with BCM4366 chipset
      brcmfmac: treat NULL character in NVRAM as separator

Rodrigo Freire (1):
      iwlwifi: Document missing module options

Sara Sharon (10):
      iwlwifi: pcie: add infrastructure for multi-queue rx
      iwlwifi: pcie: add 9000 series multi queue rx DMA support
      iwlwifi: mvm: support beacon storing
      iwlwifi: mvm: change access to ieee80211_hdr
      iwlwifi: mvm: change the check for ADD_STA status
      iwlwifi: mvm: add tlv for multi queue rx support
      iwlwifi: mvm: add new ADD_STA command version
      iwlwifi: mvm: support rss queues configuration command
      iwlwifi: pcie: enable multi-queue rx path
      iwlwifi: pcie: update iwl_mpdu_desc fields

Shengzhen Li (1):
      mwifiex: fix power state out of sync problem

Sjoerd Simons (1):
      brcmfmac: sdio: Increase the default timeouts a bit

Uri Mashiach (2):
      wlcore/wl12xx: spi: add power operation function
      wlcore/wl12xx: spi: add device tree support

Xinming Hu (10):
      mwifiex: add debugfs file to read chip information
      mwifiex: enable pcie MSIx interrupt mode support
      mwifiex: add schedule scan support
      mwifiex: display right transmit packet delay
      mwifiex: process pcie io memory read failure case
      mwifiex: skip firmware dump when read_regs() fails
      mwifiex: keep original structure in decl header file
      mwifiex: use an extensible framework for firmware dump solution
      mwifiex: dynamically increase preallocated firmware dump memory s=
ize
      mwifiex: firmware dump support for w8997 chipset

chunfan chen (5):
      mwifiex: firmware download enhancements
      mwifiex: fix IBSS data path issue.
      mwifiex: add wowlan info messages
      mwifiex: add wowlan net-detect support
      mwifiex: report wakeup reason to cfg80211

 .../bindings/net/wireless/ti,wlcore,spi.txt        |   36 ++
 drivers/bcma/bcma_private.h                        |    1 -
 drivers/bcma/driver_chipcommon.c                   |   16 +-
 drivers/bcma/driver_chipcommon_pmu.c               |   94 ++--
 drivers/bcma/driver_chipcommon_sflash.c            |    1 +
 drivers/bcma/driver_gpio.c                         |    1 +
 drivers/bcma/driver_mips.c                         |    3 -
 drivers/bcma/host_pci.c                            |    2 +-
 drivers/bcma/scan.c                                |    5 +
 drivers/net/wireless/broadcom/b43/main.c           |    8 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   23 +-
 .../wireless/broadcom/brcm80211/brcmfmac/chip.c    |   45 +-
 .../wireless/broadcom/brcm80211/brcmfmac/chip.h    |    3 +
 .../broadcom/brcm80211/brcmfmac/firmware.c         |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    4 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   13 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig         |   12 +
 drivers/net/wireless/intel/iwlwifi/dvm/led.c       |    5 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    3 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |   77 +++
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   21 +
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |    7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |   20 +-
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h |    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |   73 ++-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |   75 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |   58 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   42 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |   69 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   31 ++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |   29 ++
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   43 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   36 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   28 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |  131 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/quota.c     |   16 +
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   13 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   50 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |   17 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |   33 ++
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |    6 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |  134 ++++-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   42 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |  536 ++++++++++++=
+-------
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  155 ++++--
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   87 +++-
 drivers/net/wireless/intersil/hostap/hostap_hw.c   |   15 +-
 drivers/net/wireless/marvell/libertas/cfg.c        |   38 ++
 drivers/net/wireless/marvell/libertas/cmd.c        |   40 +-
 drivers/net/wireless/marvell/libertas/cmdresp.c    |    9 +-
 drivers/net/wireless/marvell/libertas/dev.h        |    1 +
 drivers/net/wireless/marvell/libertas/if_sdio.c    |    2 +-
 drivers/net/wireless/marvell/libertas/if_usb.c     |    1 +
 drivers/net/wireless/marvell/libertas/main.c       |    7 +-
 drivers/net/wireless/marvell/mwifiex/README        |   10 +
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |  248 ++++++++-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |   13 +
 drivers/net/wireless/marvell/mwifiex/debugfs.c     |   51 +-
 drivers/net/wireless/marvell/mwifiex/decl.h        |   24 +
 drivers/net/wireless/marvell/mwifiex/fw.h          |   90 +++-
 drivers/net/wireless/marvell/mwifiex/init.c        |   16 +-
 drivers/net/wireless/marvell/mwifiex/ioctl.h       |    5 +
 drivers/net/wireless/marvell/mwifiex/join.c        |   15 +
 drivers/net/wireless/marvell/mwifiex/main.c        |   14 +
 drivers/net/wireless/marvell/mwifiex/main.h        |   44 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  321 +++++++++---
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   50 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |  310 +++++++++++
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   35 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   23 +
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |    6 +
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |   20 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |   33 +-
 drivers/net/wireless/marvell/mwifiex/wmm.c         |    7 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |   18 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.c   |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt61pci.h       |   20 +-
 drivers/net/wireless/ti/wlcore/Kconfig             |    2 +-
 drivers/net/wireless/ti/wlcore/event.c             |    2 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   86 +++-
 include/linux/bcma/bcma.h                          |    3 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   31 +-
 94 files changed, 3046 insertions(+), 728 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,w=
lcore,spi.txt

--=20
Kalle Valo
