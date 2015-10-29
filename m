From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-10-29
Date: Thu, 29 Oct 2015 21:58:06 +0200
Message-ID: <87d1vxo3ap.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45376 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbJ2T6N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 15:58:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's hopefully my last pull request for 4.4. ssb had a new Kconfig
entry and that's why this touches arch/mips/bcm47xx/Kconfig. ssb also
did some code shuffling and moved code from b43 to ssb subsystem.
Otherwise should be business as usual.

While writing this I noticed that Fengwei Yin had a problem with the
=46rom field and that's why you see "yfw" in the stats below. I conside=
red
that this isn't a big enough problem to justify rebasing my tree, but
let me know if you think otherwise.

Please let me know if there are any problems.

Kalle

The following changes since commit 6d08f617872cc048173d59f1ce4660b030ba=
b5a6:

  net: hisilicon: updates HNS config and documents (2015-10-27 20:20:24=
 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-10-29

for you to fetch changes up to 8aaa878de83a0de3833f5b00bc822dbcd403ec36=
:

  Merge ath-next from ath.git (2015-10-29 15:34:27 +0200)

----------------------------------------------------------------

iwlwifi

* bug fix for TDLS
* fixes and cleanups in scan
* support of several scan plans
* improvements in FTM
* fixes in FW API
* improvements in the failure paths when the bus is dead
* other various small things here and there

ath10k

* add QCA9377 support
* fw_stats support for 10.4 firmware

ath6kl

* report antenna configuration to user space
* implement ethtool stats

ssb

* add Kconfig SSB_HOST_SOC for compiling SoC related code
* move functions specific to SoC hosted bus to separated file
* pick PCMCIA host code support from b43 driver

----------------------------------------------------------------
Alan Liu (1):
      ath10k: add FW API support to test mode

Alexander Bondar (1):
      iwlwifi: rs: Remove workaround that disables MIMO on P2P

Andrei Otcheretianski (1):
      iwlwifi: mvm: Implement per vif frame registration API

Arik Nemtsov (2):
      iwlwifi: mvm: correctly request DTS-measure for new cards
      iwlwifi: mvm: disable TDLS ac queues correctly

Assaf Krauss (1):
      iwlwifi: mvm: Allow setting ctrl-chnl-position in FTM responder

Avraham Stern (1):
      iwlwifi: mvm: Add support for two scheduled scan plans

Bartosz Markowski (1):
      ath10k: add QCA9377 chipset support

Ben Greear (5):
      ath6kl: report antenna configuration
      ath6kl: add error message to explain lack of HT
      ath6kl: fix firmware version assignment
      ath6kl: break stats gathering code into separate method
      ath6kl: implement ethtool stats

Bob Copeland (1):
      wcn36xx: introduce per-channel ring buffer locks

Eliad Peller (2):
      iwlwifi: avoid read/write operations if the bus is dead
      iwlwifi: mvm: take scan ref only on success

Emmanuel Grumbach (2):
      Merge remote-tracking branch 'mac80211-next/master' into next
      iwlwifi: pcie: fix (again) prepare card flow

Hamad Kadmany (1):
      wil6210: Fix TSO overflow handling

Johannes Berg (4):
      iwlwifi: mvm: use wowlan RX/TX timeouts in D0i3
      iwlwifi: mvm: use short timeouts in P2P low latency if supported
      iwlwifi: mvm: clean up some whitespace in scan code
      iwlwifi: mvm: remove pointless scan plan checks

John Linville (1):
      orinoco_usb: return error in ezusb_probe when alloc_orinocodev fa=
ils

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2015-10-25' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git

Luca Coelho (1):
      iwlwifi: mvm: let any command flag be passed to iwl_mvm_flushtx_p=
ath()

Maharaja (1):
      ath10k: enable adaptive CCA

Manikanta Pubbisetty (1):
      ath10k: add fw_stats support to 10.4 firmware

Marty Faltesek (1):
      mwifiex: toggle carrier state in start_ap/stop_ap.

Matti Gottlieb (1):
      iwlwifi: mvm: Dump FW's virtual image in the case of a NIC error

Moshe Harel (1):
      iwlwifi: nvm: free old section data when reading nvm file

Ondrej Zary (2):
      airo: Track APList_rid in struct airo_info
      airo: fix scan after SIOCSIWAP (airo_set_wap)

Rafa=C5=82 Mi=C5=82ecki (3):
      ssb: pick PCMCIA host code support from b43 driver
      ssb: move functions specific to SoC hosted bus to separated file
      ssb: add Kconfig entry for compiling SoC related code

Rajkumar Manoharan (8):
      ath10k: use local memory instead of shadow descriptor in ce_send
      ath10k: remove send completion validation in diag read/write
      ath10k: cleanup copy engine send completion
      ath10k: remove shadow copy of CE descriptors for source ring
      ath10k: remove supported chain mask
      ath10k: fill HT/VHT MCS rateset only for configured chainmask
      ath10k: move static HT/VHT capability setup functions
      ath10k: reload HT/VHT capabilities on antenna change

Vladimir Kondratiev (3):
      wil6210: ignore selected WMI events
      wil6210: fix device ready detection
      wil6210: handle failure in Tx vring config

Zefir Kurtisi (1):
      ath9k: fix phyerror codes

yfw (1):
      wcn36xx: Remove warning message when dev is NULL for arm64 dma_al=
loc.

 arch/mips/bcm47xx/Kconfig                        |    1 +
 drivers/net/wireless/airo.c                      |   77 +++--
 drivers/net/wireless/ath/ath10k/ce.c             |   57 +---
 drivers/net/wireless/ath/ath10k/ce.h             |   16 +-
 drivers/net/wireless/ath/ath10k/core.c           |   21 +-
 drivers/net/wireless/ath/ath10k/core.h           |   22 +-
 drivers/net/wireless/ath/ath10k/hw.h             |   12 +
 drivers/net/wireless/ath/ath10k/mac.c            |  346 ++++++++++++--=
--------
 drivers/net/wireless/ath/ath10k/pci.c            |   71 ++---
 drivers/net/wireless/ath/ath10k/targaddrs.h      |    3 +
 drivers/net/wireless/ath/ath10k/testmode.c       |  202 +++++++++++--
 drivers/net/wireless/ath/ath10k/wmi-ops.h        |   25 ++
 drivers/net/wireless/ath/ath10k/wmi-tlv.c        |   14 +
 drivers/net/wireless/ath/ath10k/wmi.c            |  248 ++++++++++++++=
+-
 drivers/net/wireless/ath/ath10k/wmi.h            |  148 +++++++++
 drivers/net/wireless/ath/ath6kl/cfg80211.c       |  143 +++++++++
 drivers/net/wireless/ath/ath6kl/core.h           |    2 +
 drivers/net/wireless/ath/ath6kl/debug.c          |   55 ++--
 drivers/net/wireless/ath/ath6kl/debug.h          |    2 +
 drivers/net/wireless/ath/ath6kl/init.c           |    2 +-
 drivers/net/wireless/ath/ath9k/common-debug.c    |   14 +-
 drivers/net/wireless/ath/ath9k/mac.h             |   18 +-
 drivers/net/wireless/ath/wcn36xx/dxe.c           |   61 ++--
 drivers/net/wireless/ath/wcn36xx/dxe.h           |    1 +
 drivers/net/wireless/ath/wil6210/interrupt.c     |    6 +-
 drivers/net/wireless/ath/wil6210/main.c          |    2 +-
 drivers/net/wireless/ath/wil6210/txrx.c          |   30 +-
 drivers/net/wireless/ath/wil6210/wil6210.h       |    4 +-
 drivers/net/wireless/ath/wil6210/wmi.c           |   20 +-
 drivers/net/wireless/b43/Kconfig                 |   20 --
 drivers/net/wireless/b43/Makefile                |    1 -
 drivers/net/wireless/b43/main.c                  |    9 +-
 drivers/net/wireless/b43/pcmcia.c                |  145 ---------
 drivers/net/wireless/b43/pcmcia.h                |   20 --
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h |   16 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h       |    4 +
 drivers/net/wireless/iwlwifi/iwl-trans.h         |    2 +
 drivers/net/wireless/iwlwifi/mvm/constants.h     |    4 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c   |   25 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c       |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h   |    5 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h        |   63 ++++
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c      |    3 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c      |   67 ++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h           |    2 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c           |    1 +
 drivers/net/wireless/iwlwifi/mvm/power.c         |   41 ++-
 drivers/net/wireless/iwlwifi/mvm/rs.c            |    6 -
 drivers/net/wireless/iwlwifi/mvm/scan.c          |  120 ++++----
 drivers/net/wireless/iwlwifi/mvm/sta.c           |    9 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c    |    2 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c            |   11 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c            |    4 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c        |   10 +-
 drivers/net/wireless/mwifiex/cfg80211.c          |    8 +
 drivers/net/wireless/mwifiex/uap_event.c         |    7 -
 drivers/net/wireless/orinoco/orinoco_usb.c       |    1 +
 drivers/ssb/Kconfig                              |    9 +
 drivers/ssb/Makefile                             |    3 +-
 drivers/ssb/bridge_pcmcia_80211.c                |  128 ++++++++
 drivers/ssb/host_soc.c                           |  173 +++++++++++
 drivers/ssb/main.c                               |  172 +----------
 drivers/ssb/ssb_private.h                        |   16 +
 63 files changed, 1843 insertions(+), 889 deletions(-)
 delete mode 100644 drivers/net/wireless/b43/pcmcia.c
 delete mode 100644 drivers/net/wireless/b43/pcmcia.h
 create mode 100644 drivers/ssb/bridge_pcmcia_80211.c
 create mode 100644 drivers/ssb/host_soc.c

--=20
Kalle Valo
