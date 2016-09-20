From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2016-09-20
Date: Tue, 20 Sep 2016 13:20:46 +0300
Message-ID: <87vaxq3m9t.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

last pull request for 4.8, unless something really drastic comes up. And
a small one even, just a small fix to iwlwifi to avoid a firmware crash.

Please let me know if there are any problems.

Kalle

The following changes since commit a0714125d11bcf21599b08b25fdaf384c0db6712:

  Merge ath-current from ath.git (2016-09-07 20:16:37 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2016-09-20

for you to fetch changes up to db64c5fa590b5d82ac0d5ec39bc498f95094e66b:

  Merge tag 'iwlwifi-for-kalle-2016-09-15' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2016-09-17 17:06:22 +0300)

----------------------------------------------------------------

wireless-drivers fixes for 4.8

iwlwifi

* fix to prevent firmware crash when sending off-channel frames

----------------------------------------------------------------
Beni Lev (1):
      iwlwifi: mvm: update TX queue before making a copy of the skb

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-09-15' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

 drivers/net/wireless/intel/iwlwifi/mvm/tx.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)
