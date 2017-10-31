From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-10-31
Date: Tue, 31 Oct 2017 17:19:24 +0200
Message-ID: <871slj1h1f.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request to net tree for 4.14. Due to the ath10k security
issue I would like to get this to 4.14 still.

Please let me know if there are any problems.

Kalle

The following changes since commit a6127b4440d1f74f26b64006b2f50c9dc6d66efc:

  Merge tag 'iwlwifi-for-kalle-2017-10-06' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2017-10-09 17:31:39 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-10-31

for you to fetch changes up to c29f56b9f425c63daa3f3163ee16493b1c67618b:

  Merge ath-current from ath.git (2017-10-31 16:26:48 +0200)

----------------------------------------------------------------
wireless-drivers fixes for 4.14

The most important here is the security vulnerabitility fix for
ath10k.

ath10k

* fix security vulnerability with missing PN check on certain hardware

* revert ath10k napi fix as it caused regressions on QCA6174

wcn36xx

* remove unnecessary rcu_read_unlock() from error path

----------------------------------------------------------------
Jia-Ju Bai (1):
      wcn36xx: Remove unnecessary rcu_read_unlock in wcn36xx_bss_info_changed

Kalle Valo (2):
      Revert "ath10k: fix napi_poll budget overflow"
      Merge ath-current from ath.git

Vasanthakumar Thiagarajan (1):
      ath10k: rebuild crypto header in rx data frames

 drivers/net/wireless/ath/ath10k/htt_rx.c  | 122 +++++++++++++++++++++++-------
 drivers/net/wireless/ath/ath10k/rx_desc.h |   3 +
 drivers/net/wireless/ath/wcn36xx/main.c   |   1 -
 3 files changed, 98 insertions(+), 28 deletions(-)
