From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2016-01-09
Date: Sat, 09 Jan 2016 10:44:51 +0200
Message-ID: <87k2nji1ks.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

these are the last -next patches I would like to get to 4.5. Only few
new features, mostly bugfixes. Please let me know if there are any
problems.

Kalle

The following changes since commit 00ce3a15d811978fcb204a1a3f5f8c059096fa5e:

  soreuseport: change consume_skb to kfree_skb in error case (2016-01-06 01:30:27 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-01-09

for you to fetch changes up to 42e0ed0d454c6ad7be67f2c18828391ecfdc9a62:

  brcmfmac: Do not handle link downs for ibss. (2016-01-08 10:44:48 +0200)

----------------------------------------------------------------
brcmfmac

* query features through firmware command
* ARP offload through inet notifier
* force probe to succeed for debugging purposes
* random mac support for scheduled scan
* support wowl upon net detect

iwlwifi

* bug fixes and improvements for firmware debug system
* advertise support for Rx A-MSDU in A-MPDU
* support -20.ucode
* fix WoWLAN for iwldvm
* preparations towards multiple Rx queues
* platform power improvements for GO mode when no clients are associated

----------------------------------------------------------------
Alexey Khoroshilov (1):
      ipw2x00: add checks for dma mapping errors

Amitkumar Karwar (1):
      mwifiex: reduce cloned skb queue size

Andrzej Hajda (1):
      ath9k_htc: fix handling return value of ath9k_hw_calibrate

Arend van Spriel (5):
      brcmfmac: obtain feature info using 'cap' firmware command
      brcmfmac: introduce module parameter to force successful probe
      brcmfmac: change brcmf_sdio_wd_timer() prototype
      brcmfmac: use msecs_to_jiffies() in macro definitions
      brcmfmac: use jiffies for timeout in btcoex

Ayala Beker (1):
      iwlwifi: mvm: don't ask beacons when P2P GO vif and no assoc sta

Dan Carpenter (2):
      wil6210: fix a warning message condition
      ath9k: fix ath9k_hw_nvram_check_version()

David Spinadel (1):
      iwlwifi: mvm: fix extended dwell time

Eliad Peller (1):
      iwlwifi: mvm: initialize gtkdata->mvm correctly

Emmanuel Grumbach (10):
      iwlwifi: dvm: fix WoWLAN
      iwlwifi: mvm: let the firmware choose the antenna for beacons
      iwlwifi: mvm: reset mvm->scan_type when firmware is started
      iwlwifi: set max firmware version of 7265 to 17
      iwlwifi: mvm: bump max API to 20
      iwlwifi: mvm: dump the radio registers when the firmware crashes
      iwlwifi: mvm: remove useless WARN_ON and rely on cfg80211's combination
      iwlwifi: mvm: constify the parameters of a few functions in fw-dbg.c
      iwlwifi: mvm: fix memory leaks in error paths upon fw error dump
      iwlwifi: pcie: properly configure the debug buffer size for 8000

Fengwei Yin (2):
      wcn36xx: handle rx skb allocation failure to avoid system crash
      wcn36xx: split DMA mask register writing.

Franky Lin (1):
      brcmfmac: add arp offload ip address table configuration support

Golan Ben-Ami (1):
      iwlwifi: mvm: add a non-trigger window to fw dbg triggers

Hamad Kadmany (1):
      wil6210: fix kernel OOPS when stopping interface during Rx traffic

Hante Meuleman (7):
      brcmfmac: Add get_station support for IBSS
      brcmfmac: Add support for scheduled scan mac randomization
      brcmfmac: Fix warn trace on module unload while in ibss mode
      brcmfmac: Move all module parameters to one place
      brcmfmac: Add wowl net detect support
      brcmfmac: Reshuffle functions to avoid forward declarations
      brcmfmac: Do not handle link downs for ibss.

Insu Yun (1):
      mwifiex: correctly handling kzalloc

Jia-Ju Bai (1):
      rt2x00pci: Disable memory-write-invalidate when the driver exits

Johannes Berg (4):
      iwlwifi: mvm: support A-MSDU in A-MPDU
      iwlwifi: mvm: prevent multiple stations with the same address
      iwlwifi: mvm: check PN for CCMP/GCMP in the driver
      iwlwifi: mvm: check minimum temperature notification length

Julia Lawall (1):
      iwlegacy: 4965-mac: constify il_sensitivity_ranges structure

Kalle Valo (2):
      Merge ath-next from ath.git
      Merge tag 'iwlwifi-next-for-kalle-2016-01-07_2' of https://git.kernel.org/.../iwlwifi/iwlwifi-next

Lior David (1):
      wil6210: support for platform specific crash recovery

Matti Gottlieb (1):
      iwlwifi: mvm: change mcc update API

Oren Givon (2):
      iwlwifi: update and fix 7265 series PCI IDs
      iwlwifi: nvm: fix loading default NVM file

Pawel Kulakowski (1):
      ath9k: Enable support for cloned SKBS

Peter Oh (1):
      ath10k: set SM power save disabled to default value

Rajkumar Manoharan (2):
      ath10k: wake up device before accessing registers
      ath10k: reduce indentation by moving powersave check within function

Xinming Hu (2):
      mwifiex: fix missing debug messages
      mwifiex: increase priority for critical message

 drivers/net/wireless/ath/ath10k/mac.c              |    3 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   38 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    2 +-
 drivers/net/wireless/ath/ath9k/init.c              |    1 +
 drivers/net/wireless/ath/wcn36xx/dxe.c             |   43 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |    8 +-
 drivers/net/wireless/ath/wil6210/main.c            |    2 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   30 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   12 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |    1 +
 drivers/net/wireless/ath/wil6210/wil_crash_dump.c  |    3 +-
 drivers/net/wireless/ath/wil6210/wil_platform.c    |    3 +-
 drivers/net/wireless/ath/wil6210/wil_platform.h    |   38 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |   12 +-
 .../wireless/broadcom/brcm80211/brcmfmac/btcoex.c  |   12 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 1173 ++++++++++++--------
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |   29 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |   72 ++
 .../wireless/broadcom/brcm80211/brcmfmac/common.h  |   56 +
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  136 ++-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    7 +-
 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |   76 +-
 .../wireless/broadcom/brcm80211/brcmfmac/feature.h |    4 +-
 .../broadcom/brcm80211/brcmfmac/firmware.c         |   16 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fwil.h    |    1 +
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |   36 +
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |    9 +-
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |    4 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   18 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    7 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   51 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.h    |    6 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |    5 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |   11 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    2 +-
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   12 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |    6 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |  115 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |   60 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |   62 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.h    |   30 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   53 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   49 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |   55 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |    2 -
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |  106 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   13 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   12 +
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |    5 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   17 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   32 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   15 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00pci.c     |    2 +
 64 files changed, 1783 insertions(+), 823 deletions(-)

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
