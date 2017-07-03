From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2017-07-03
Date: Mon, 03 Jul 2017 14:39:07 +0300
Message-ID: <87r2xxkaw4.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's the late pull request to net-next I mentioned about last week to
get some new iwlwifi hw support to 4.13.

If this is too late just drop the request and let me know, I can then
resend it for 4.14 after the merge window. These patches were included
in today's linux-next build and I haven't received any reports about
problems, at least not yet.

Kalle

The following changes since commit fdcbe65d618af080ee23229f0137ffd37f2de36b:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git (2017-06-28 22:10:48 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2017-07-03

for you to fetch changes up to 17d9aa66b08de445645bd0688fc1635bed77a57b:

  Merge tag 'iwlwifi-next-for-kalle-2017-06-30' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next (2017-06-30 13:48:19 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.13

Last minute changes to get new hardware and firmware support for
iwlwifi and few other changes I was able to squeeze in. Also two
patches for ieee80211.h and nl80211 as Johannes is away.

Major changes:

iwlwifi

* some important fixes for 9000 HW

* support for version 30 of the FW API for 8000 and 9000 series

* a few new PCI IDs for 9000 series

* reorganization of common files

brcmfmac

* support 4-way handshake offloading for WPA/WPA2-PSK and 802.1X

----------------------------------------------------------------
Andrei Otcheretianski (1):
      nl80211: Don't verify owner_nlportid on NAN commands

Arend van Spriel (3):
      brcmfmac: support 4-way handshake offloading for WPA/WPA2-PSK
      brcmfmac: support 4-way handshake offloading for 802.1X
      brcmfmac: switch to using cfg80211_connect_done()

Emmanuel Grumbach (5):
      iwlwifi: mvm: change when the BT_COEX is sent
      iwlwifi: mvm: don't send fetch the TID from a non-QoS packet in TSO
      iwlwifi: mvm: don't mess the SNAP header in TSO for non-QoS packets
      iwlwifi: pcie: propagate iwl_pcie_apm_init's status
      iwlwifi: pcie: wait longer after device reset

Ganapathi Bhat (1):
      mwifiex: do not update MCS set from hostapd

Haim Dreyfuss (2):
      iwlwifi: mvm: refactor geo init
      iwlwifi: mvm: Add debugfs entry to retrieve SAR geographic profile

Johannes Berg (31):
      iwlwifi: mvm: remove some CamelCase from firmware API
      iwlwifi: mvm: fix various "Excess ... description" kernel-doc warnings
      iwlwifi: mvm: remove various unused command IDs/structs
      iwlwifi: mvm: use __le16 even for reserved fields
      iwlwifi: mvm: add documentation for all command IDs
      iwlwifi: mvm: fix a bunch of kernel-doc warnings
      iwlwifi: dvm: use macros for format strings
      iwlwifi: pcie: only apply retention workaround on 9000-series A-step
      iwlwifi: pcie: fix 9000-series RF-kill interrupt propagation
      iwlwifi: mvm: use proper CDB check in PHY context modify
      iwlwifi: pcie: improve "invalid queue" warning
      iwlwifi: pcie: improve debug in iwl_pcie_rx_handle_rb()
      iwlwifi: unify external & internal modparam names
      iwlwifi: pcie: make ctxt-info free idempotent
      iwlwifi: pcie: warn if paging is already initialized during init
      iwlwifi: mvm: unconditionally stop device after init
      iwlwifi: mvm: fix deduplication start logic
      iwlwifi: mvm: rename iwl_shared_mem_cfg_v1 to the correct _v2
      iwlwifi: create new subdirectory for FW interaction
      iwlwifi: move notification wait into fw/
      iwlwifi: move configuration into sub-directory
      iwlwifi: mvm: remove version 2 of paging command
      iwlwifi: mvm: quietly accept non-sta assoc response frames
      iwlwifi: pcie: add MSI-X interrupt tracing
      iwlwifi: mvm: properly enable IP header checksumming
      iwlwifi: mvm: fix mac80211 queue tracking
      iwlwifi: mvm: map cab_queue to real one earlier
      iwlwifi: mvm: fix mac80211's hw_queue in DQA mode
      iwlwifi: pcie: reconfigure MSI-X HW on resume
      iwlwifi: mvm: remove DQA non-STA client mode special case
      iwlwifi: mvm: quietly accept non-sta disassoc frames

Kalle Valo (1):
      Merge tag 'iwlwifi-next-for-kalle-2017-06-30' of git://git.kernel.org/.../iwlwifi/iwlwifi-next

Liad Kaufman (3):
      iwlwifi: mvm: support aggs of 64 frames in A000 family
      iwlwifi: mvm: support multi tid ba notif
      iwlwifi: mvm: update rx statistics cmd api

Luca Coelho (2):
      iwlwifi: mvm: simplify CHECK_MLME_TRIGGER macro
      iwlwifi: bump MAX API for 8000/9000/A000 to 33

Peter Oh (1):
      ieee80211: update public action codes

Sharon Dvir (1):
      iwlwifi: mvm: change sta_id to u8

Tzipi Peres (2):
      iwlwifi: add the new a000_2ax series
      iwlwifi: add twelve new 9560 series PCI IDs

 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 150 +++++++-
 .../broadcom/brcm80211/brcmfmac/cfg80211.h         |  15 +-
 .../wireless/broadcom/brcm80211/brcmfmac/feature.c |   1 +
 .../wireless/broadcom/brcm80211/brcmfmac/feature.h |   4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.h    |  30 ++
 .../wireless/broadcom/brcm80211/brcmfmac/fwil.h    |   1 +
 .../broadcom/brcm80211/brcmfmac/fwil_types.h       |  16 +
 drivers/net/wireless/intel/iwlwifi/Makefile        |   6 +-
 .../intel/iwlwifi/{iwl-1000.c => cfg/1000.c}       |   0
 .../intel/iwlwifi/{iwl-2000.c => cfg/2000.c}       |   0
 .../intel/iwlwifi/{iwl-5000.c => cfg/5000.c}       |   0
 .../intel/iwlwifi/{iwl-6000.c => cfg/6000.c}       |   0
 .../intel/iwlwifi/{iwl-7000.c => cfg/7000.c}       |   0
 .../intel/iwlwifi/{iwl-8000.c => cfg/8000.c}       |   4 +-
 .../intel/iwlwifi/{iwl-9000.c => cfg/9000.c}       |   2 +-
 .../intel/iwlwifi/{iwl-a000.c => cfg/a000.c}       |  12 +-
 drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c   |  15 +-
 drivers/net/wireless/intel/iwlwifi/dvm/dev.h       |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |   8 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c        |   2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rxon.c      |   2 +-
 .../intel/iwlwifi/{iwl-fw-api.h => fw/api.h}       |  24 ++
 .../{iwl-fw-error-dump.h => fw/error-dump.h}       |   0
 .../intel/iwlwifi/{iwl-fw-file.h => fw/file.h}     |   4 +
 .../wireless/intel/iwlwifi/{iwl-fw.h => fw/img.h}  |  10 +-
 .../iwlwifi/{iwl-notif-wait.c => fw/notif-wait.c}  |   2 +-
 .../iwlwifi/{iwl-notif-wait.h => fw/notif-wait.h}  |   0
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |   1 +
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |   2 +-
 .../net/wireless/intel/iwlwifi/iwl-devtrace-io.h   |  26 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |  14 +-
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |  16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c    |  18 -
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |   8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   | 293 +++++++++++-----
 .../net/wireless/intel/iwlwifi/mvm/fw-api-coex.h   |  11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h |  11 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |   5 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-power.h  |   9 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h |   3 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |  37 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |  36 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |  63 +++-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-stats.h  | 167 +++++++--
 .../net/wireless/intel/iwlwifi/mvm/fw-api-tof.h    |  14 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    | 376 ++++++++++++++++-----
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.h    |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        | 123 ++++---
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |  32 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |  32 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  33 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  35 +-
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h        |   2 +
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |  83 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  32 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.c    |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        | 101 +++---
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  10 +-
 .../net/wireless/intel/iwlwifi/pcie/ctxt-info.c    |   7 +
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |  25 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |  17 +
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |  41 ++-
 .../net/wireless/intel/iwlwifi/pcie/trans-gen2.c   |   8 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  46 ++-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   5 -
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |  22 --
 include/linux/ieee80211.h                          |  35 +-
 include/uapi/linux/nl80211.h                       |   9 +-
 net/wireless/nl80211.c                             |   8 -
 77 files changed, 1538 insertions(+), 628 deletions(-)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-1000.c => cfg/1000.c} (100%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-2000.c => cfg/2000.c} (100%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-5000.c => cfg/5000.c} (100%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-6000.c => cfg/6000.c} (100%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-7000.c => cfg/7000.c} (100%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-8000.c => cfg/8000.c} (99%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-9000.c => cfg/9000.c} (99%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-a000.c => cfg/a000.c} (94%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-fw-api.h => fw/api.h} (93%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-fw-error-dump.h => fw/error-dump.h} (100%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-fw-file.h => fw/file.h} (99%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-fw.h => fw/img.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-notif-wait.c => fw/notif-wait.c} (99%)
 rename drivers/net/wireless/intel/iwlwifi/{iwl-notif-wait.h => fw/notif-wait.h} (100%)
