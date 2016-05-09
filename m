From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-05-09
Date: Mon, 09 May 2016 22:06:42 +0300
Message-ID: <8760unhwzh.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

one more iwlwifi fix we would like to get to 4.6 if possible. Please let
me know if there are any problems.

Kalle

The following changes since commit e2841ea91611622370f66b4dfaa62599e8850d48:

  Merge tag 'iwlwifi-for-kalle-2016-04-12_2' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-04-21 15:40:13 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-05-09

for you to fetch changes up to cbbba30f1ac95a04aae9c61a55aebe5e6fdf29f0:

  Merge tag 'iwlwifi-for-kalle-2016-05-04' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-05-06 14:27:48 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.6

iwlwifi

* fix P2P rates (and possibly other issues)

----------------------------------------------------------------
Emmanuel Grumbach (1):
      iwlwifi: mvm: don't override the rate with the AMSDU len

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-05-04' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

 drivers/net/wireless/intel/iwlwifi/mvm/tx.c |   83 ++++++++++++++++-----------
 1 file changed, 48 insertions(+), 35 deletions(-)
