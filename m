From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-04-09
Date: Thu, 09 Apr 2015 14:26:07 +0300
Message-ID: <87lhi1fsq8.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a smaller pull request which I'm hoping still get to 4.1. Please
let me know if there are any problems.

Kalle

The following changes since commit 7abccdba25be45630eede85053496f1f48d3=
6ec8:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/bluetooth/bluetooth-next (2015-04-07 11:47:52 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-04-09

for you to fetch changes up to f56d9e23b78e311fbd992a1bd80b8bf2adaee29b=
:

  ssb: add delay after PCI reset to fix SoC reboots (2015-04-07 20:18:1=
0 +0300)

----------------------------------------------------------------
Major changes:

iwlwifi:

* some more work on LAR
* fixes for UMAC scan
* more work on debugging framework
* more work for 8000 devices
* cleanups and small bugfixes

----------------------------------------------------------------
Alexander Bondar (1):
      iwlwifi: mvm: Clean up UMAC scan UIDs in the reset and drv_stop f=
lows

Arik Nemtsov (3):
      iwlwifi: mvm: assign new TLV bit for multi-source LAR
      iwlwifi: mvm: remove d0i3 ref correctly during AP start
      iwlwifi: mvm: always reconfigure last MCC on init

David Spinadel (1):
      iwlwifi: mvm: inform mac80211 about umac scans that was aborted b=
y restart

Eliad Peller (2):
      iwlwifi: mvm: take IWL_MVM_REF_UCODE_DOWN before restarting hw
      iwlwifi: pcie: initialize trans_pcie->ref_count on configure()

Emmanuel Grumbach (8):
      iwlwifi: mvm: properly flush the queues for buffering transport
      iwlwifi: drop support for early versions of 8000
      iwlwifi: mvm: allow to configure the timeout for the Tx queues
      iwlwifi: check the size of the trigger struct from the firmware f=
ile
      Merge tag 'mac80211-next-for-davem-2015-03-30' into iwlwifi-next
      iwlwifi: mvm: add trigger for firmware dump upon MLME failures
      iwlwifi: mvm: add trigger for time events
      iwlwifi: mvm: capture connection loss as part of MLME trigger

Eran Harary (3):
      iwlwifi: mvm: don't wait for firmware verification
      iwlwifi: mvm: fix debug print in the RSA ownership workaround
      iwlwifi: 8000: change PNVM in case it doesn't match to the HW ste=
p

Eyal Shapira (1):
      iwlwifi: mvm: rs: refactor rs_update_rate_tbl

=46red Chou (1):
      ath9k_htc: check seq number instead of cmd id for timeout

Joe Perches (1):
      wireless: Use bool function returns of true/false instead of 1/0

Johannes Berg (5):
      iwlwifi: mvm: continue (with error) CSA on GO time event failure
      iwlwifi: mvm: remove time-event start/end failure warning
      iwlwifi: mvm: remove unused arguments
      iwlwifi: mvm: don't return uninitialized value in get_survey()
      iwlwifi: mvm: do string formatting in debug triggers

Kalle Valo (1):
      Merge tag 'iwlwifi-next-for-kalle-2015-04-02' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next

Liad Kaufman (3):
      iwlwifi: pcie: add rx packet sequence number to dbg print
      iwlwifi: mvm: add iccm data to 8000 b-step data dump
      iwlwifi: mvm: rs: fix comment indentation

Luciano Coelho (3):
      iwlwifi: mvm: add delay to scheduled scan
      iwlwifi: mvm: use debugfs_create_bool() for enable_scan_iteration=
_notif
      iwlwifi: mvm: add debugfs entry with the number of net-detect sca=
ns

Masanari Iida (1):
      wl1251: Fix typo in MODULE_DESCRIPTION in wl1251/main.c

Matti Gottlieb (1):
      iwlwifi: mvm: Fix wrongfully flushing frames in the roc/off chann=
el queue

Miaoqing Pan (1):
      ath9k: add extra GPIO led support

Rafa=C5=82 Mi=C5=82ecki (1):
      ssb: add delay after PCI reset to fix SoC reboots

Sara Sharon (1):
      iwlwifi: fix spelling errors

Taehee Yoo (1):
      rtlwifi: Add encryption argument in rtl_is_special_data for check=
ing DHCP packet.

 drivers/net/wireless/ath/ath9k/gpio.c              |    8 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   17 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    1 +
 drivers/net/wireless/ath/ath9k/reg.h               |    4 +
 drivers/net/wireless/ath/ath9k/wmi.c               |   12 +-
 drivers/net/wireless/ath/ath9k/wmi.h               |    2 +-
 drivers/net/wireless/b43/dma.c                     |   12 +-
 drivers/net/wireless/b43legacy/dma.c               |    6 +-
 drivers/net/wireless/b43legacy/rfkill.c            |    8 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |    2 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   10 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   42 +++--
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom-read.c     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |   12 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   85 +++++++++-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   13 +-
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |   57 ++-----
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.h       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   25 +--
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   12 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    6 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |   31 +---
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    4 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-mac.h      |    2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |   14 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   23 ++-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |    7 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  166 ++++++++++++=
+++++---
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   24 ++-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   63 +++++---
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   34 ++--
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    2 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   19 +--
 drivers/net/wireless/iwlwifi/mvm/rx.c              |    4 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   73 ++++++++-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   28 +++-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |    6 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   81 ++++++++--
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    4 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    8 +
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   72 ++++++++-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    8 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   62 +++-----
 drivers/net/wireless/rtlwifi/base.c                |    7 +-
 drivers/net/wireless/rtlwifi/base.h                |    3 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    2 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    5 +-
 drivers/net/wireless/ti/wl1251/main.c              |    2 +-
 drivers/ssb/driver_pcicore.c                       |    9 ++
 55 files changed, 784 insertions(+), 344 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
