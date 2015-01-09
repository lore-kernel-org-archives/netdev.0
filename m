From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-01-09
Date: Fri, 09 Jan 2015 18:31:30 +0200
Message-ID: <87lhlbj4pp.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:57445 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468AbbAIQbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 11:31:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are few more fixes to 3.19. Please let me know if there are any
problems.

Kalle

The following changes since commit 7ce67a38f799d1fb332f672b117efbadedaa5352:

  net: ethernet: cpsw: fix hangs with interrupts (2015-01-04 22:18:34 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-01-09

for you to fetch changes up to c702674f99e612a22cf6e8f9b4bec341257970c0:

  Merge tag 'iwlwifi-for-kalle-2015-01-05' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-01-05 12:07:04 +0200)

----------------------------------------------------------------

* rtlwifi: fix a regression in large skb allocation failure

iwlwifi:

* fix for 7265D NVM check
* fixes for scan: fix long scanning times and network discovery
* new firmware API for iwlmvm supported devices
* fixes in rate control

----------------------------------------------------------------
Arik Nemtsov (1):
      iwlwifi: pcie: correctly define 7265-D cfg

David Spinadel (2):
      iwlwifi: mvm: add a flag to enable match found notification
      iwlwifi: mvm: scan dwell time corrections

Emmanuel Grumbach (2):
      iwlwifi: 7000: fix reported firmware name for 7265D
      iwlwifi: bump firmware API for mvm devices to 12

Eyal Shapira (2):
      iwlwifi: mvm: fix Rx with both chains
      iwlwifi: mvm: fix out of bounds access to tid_to_mac80211_ac

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-01-05' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Fix error when accessing unmapped memory in skb

 drivers/net/wireless/iwlwifi/iwl-7000.c        |    6 ++---
 drivers/net/wireless/iwlwifi/iwl-8000.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h     |    4 +++
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h |    2 ++
 drivers/net/wireless/iwlwifi/mvm/scan.c        |   19 ++++++++++----
 drivers/net/wireless/iwlwifi/mvm/tx.c          |    8 ++++--
 drivers/net/wireless/iwlwifi/mvm/utils.c       |    2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c        |    4 ++-
 drivers/net/wireless/rtlwifi/pci.c             |   32 ++++++++++++++++++------
 9 files changed, 58 insertions(+), 21 deletions(-)

-- 
Kalle Valo
