From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-04-01
Date: Wed, 01 Apr 2015 19:59:39 +0300
Message-ID: <87mw2rzsw3.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

one last pull request for 4.0, I hope I'm not too late on this one. Only
one iwlwifi memory leak fix this time. Please let me know if there are
any problems.

Kalle

The following changes since commit 6ae4ccfee09efe5baa3951d1c1d27050a46a1469:

  Merge tag 'iwlwifi-for-kalle-2014-03-22' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-03-23 06:43:43 +0200)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-04-01

for you to fetch changes up to 69628cd0652a091591ef44ac07c150063b789c4a:

  Merge tag 'iwlwifi-for-kalle-2015-03-30' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-03-30 09:39:12 +0300)

----------------------------------------------------------------

iwlwifi:

* fix a memory leak, we leaked memory each time the module
  was loaded.

----------------------------------------------------------------
Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-03-30' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      iwlwifi: Fix memory leak in iwl_req_fw_callback()

 drivers/net/wireless/iwlwifi/iwl-drv.c |    1 +
 1 file changed, 1 insertion(+)

-- 
Kalle Valo
