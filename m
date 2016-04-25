From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-04-25
Date: Mon, 25 Apr 2016 19:13:20 +0300
Message-ID: <87a8kh3bvj.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39901 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865AbcDYQN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 12:13:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

few fixes for 4.6, more info in the signed tag below. I'm hoping this to
be the final pull request for 4.6 but let's see how it goes. Please let
me know if there are any problems.

Kalle

The following changes since commit 15da5d11040c636cddf85bd93fd4abe85f02fc9f:

  Merge tag 'iwlwifi-for-kalle-2016-03-30' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-04-02 17:59:57 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-04-25

for you to fetch changes up to e2841ea91611622370f66b4dfaa62599e8850d48:

  Merge tag 'iwlwifi-for-kalle-2016-04-12_2' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-04-21 15:40:13 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.6

ath9k

* fix a couple release old throughput regression on ar9281

iwlwifi

* add new device IDs for 8265
* fix a NULL pointer dereference when paging firmware asserts
* remove a WARNING on gscan capabilities
* fix MODULE_FIRMWARE for 8260

----------------------------------------------------------------
Ayala Beker (1):
      iwlwifi: mvm: avoid to WARN about gscan capabilities

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-04-12_2' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Matti Gottlieb (1):
      iwlwifi: mvm: fix accessing Null pointer during fw dump collection

Oleksij Rempel (1):
      ath9k: ar5008_hw_cmn_spur_mitigate: add missing mask_m & mask_p initialisation

Oren Givon (1):
      iwlwifi: add device IDs for the 8265 device

Sara Sharon (1):
      iwlwifi: 8000: fix MODULE_FIRMWARE input

 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |    8 +++----
 drivers/net/wireless/ath/ath9k/ar9002_phy.c     |    5 -----
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c    |   26 +++++++++--------------
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c |    6 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c     |    2 ++
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c   |   10 +++++++++
 7 files changed, 30 insertions(+), 29 deletions(-)
