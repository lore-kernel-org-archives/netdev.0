From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2017-04-03
Date: Mon, 03 Apr 2017 14:26:10 +0300
Message-ID: <87a87xohpp.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here few really small fixes. I'm hoping this to be the last pull request
for 4.11.

Please let me if there are any problems.

Kalle

The following changes since commit 6be3b6cce1e225f189b68b4e84fc711d19b4277b:

  ath10k: fix incorrect wlan_mac_base in qca6174_regs (2017-03-20 17:11:31 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-04-03

for you to fetch changes up to d77facb88448cdeaaa3adba5b9704a48ac2ac8d6:

  brcmfmac: use local iftype avoiding use-after-free of virtual interface (2017-03-30 19:43:51 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.11

iwlwifi

* an RCU fix
* a fix for a potential out-of-bounds access crash
* a fix for IBSS which has been broken since DQA was enabled

rtlwifi

* fix scheduling while atomic regression

brcmfmac

* fix use-after-free bug found by KASAN

----------------------------------------------------------------
Arend Van Spriel (1):
      brcmfmac: use local iftype avoiding use-after-free of virtual interface

Dan Carpenter (1):
      iwlwifi: mvm: writing zero bytes to debugfs causes a crash

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-03-29' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Fix scheduling while atomic splat

Liad Kaufman (1):
      iwlwifi: mvm: support ibss in dqa mode

Sara Sharon (1):
      iwlwifi: mvm: fix accessing fw_id_to_mac_id

 drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c | 8 +++++---
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c       | 2 ++
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c      | 3 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c      | 2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c           | 9 ++++++---
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c            | 7 +++++--
 drivers/net/wireless/realtek/rtlwifi/base.c            | 6 ++++--
 7 files changed, 25 insertions(+), 12 deletions(-)
