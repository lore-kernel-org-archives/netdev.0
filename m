From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers 2016-06-21
Date: Tue, 21 Jun 2016 13:27:16 +0300
Message-ID: <87eg7qn8fv.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here is a pull request for 4.7, really small fixes this time, some of
them fix important regressions. Please let me know if there are any
problems.

Kalle

The following changes since commit 182fd9eecb287e696c82b30d06c6150d80a49c5b:

  MAINTAINERS: Add file patterns for wireless device tree bindings (2016-06-04 17:24:02 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-06-21

for you to fetch changes up to 034fdd4a17ff089c2428ece18efa65c5396810d2:

  Merge ath-current from ath.git (2016-06-16 17:55:19 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.7

iwlwifi

* fix the scan timeout for long scans
* fix an RCU splat caused when updating the TKIP key
* fix a potential NULL-derefence introduced recently
* fix a IGTK key bug that has existed since the MVM driver was introduced
* fix some fw capabilities checks that got accidentally inverted

rtl8xxxu

* fix typo on variable name

ath10k

* fix deadlock when peer cannot be created
* fix crash related to printing features
* fix deadlock while processing rx_in_ord_ind

ath9k

* fix GPIO mask regression for AR9462 and AR9565

----------------------------------------------------------------
Ayala Beker (1):
      iwlwifi: mvm: set the encryption type of an IGTK key

Ben Greear (2):
      ath10k: fix deadlock when peer cannot be created
      ath10k: fix crash related to printing features

Colin Ian King (1):
      rtl8xxxu: fix typo on variable name, compare against correct variable

Emmanuel Grumbach (1):
      iwlwifi: mvm: fix RCU splat in TKIP's update_key

Johannes Berg (1):
      iwlwifi: mvm: fix a few firmware capability checks

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2016-06-10' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Luca Coelho (2):
      iwlwifi: mvm: increase scan timeout to 20 seconds
      iwlwifi: mvm: fix potential NULL-dereference in iwl_mvm_reorder()

Miaoqing Pan (1):
      ath9k: fix GPIO mask for AR9462 and AR9565

Rajkumar Manoharan (1):
      ath10k: fix deadlock while processing rx_in_ord_ind

 drivers/net/wireless/ath/ath10k/core.c             |    2 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    1 -
 drivers/net/wireless/ath/ath10k/mac.c              |    2 +-
 drivers/net/wireless/ath/ath9k/reg.h               |    8 ++++----
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |    8 ++++----
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |    4 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |   16 +++++++++++++++-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |    2 +-
 9 files changed, 30 insertions(+), 15 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
