From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-12-28
Date: Mon, 28 Dec 2015 13:47:43 +0200
Message-ID: <87ziwure00.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39234 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbL1Lrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 06:47:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's one more pull request, a bit late due to holidays but I hope this
still makes it to 4.4. Just two small fixes to iwlwifi, nothing else.

Kalle

The following changes since commit eeec5d0ef7ee54a75e09e861c3cc44177b8752c7:

  rtlwifi: rtl8821ae: Fix lockups on boot (2015-11-17 15:58:53 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-12-28

for you to fetch changes up to 01d85b9b2b6bec2b0773cf2afc58699dc4b052f8:

  Merge tag 'iwlwifi-for-kalle-2015-12-16' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-12-18 14:57:02 +0200)

----------------------------------------------------------------

iwlwifi

* don't load firmware that won't exist for 7260
* fix RCU splat

----------------------------------------------------------------
Johannes Berg (2):
      iwlwifi: separate firmware version for 7260 devices
      iwlwifi: mvm: protect RCU dereference in iwl_mvm_get_key_sta_id

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-12-16' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

 drivers/net/wireless/iwlwifi/iwl-7000.c |   49 ++++++++++++++++++++++---------
 drivers/net/wireless/iwlwifi/mvm/sta.c  |   15 ++++++----
 2 files changed, 44 insertions(+), 20 deletions(-)
