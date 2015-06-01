From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2015-06-01
Date: Mon, 01 Jun 2015 09:29:32 +0300
Message-ID: <874mmsvt4j.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40601 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbbFAG3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 02:29:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are three more important fixes I'm hoping to get to 4.1 still, I
hope I'm not too late with these. Please let me know if there are any
problems.

Kalle

The following changes since commit aefa441b150279dd8d25658e018898a3fe9a6769:

  Merge tag 'iwlwifi-for-kalle-2015-05-21' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-05-22 10:47:02 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2015-06-01

for you to fetch changes up to 38fe44e61a894f1c7b3e60b0614030271070ea53:

  Merge tag 'iwlwifi-for-kalle-2015-05-28' of https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2015-05-28 16:28:03 +0300)

----------------------------------------------------------------

iwlwifi:

* fix OTP parsing 8260
* fix powersave handling for 8260

brcmfmac:

* fix null pointer crash

----------------------------------------------------------------
Arend van Spriel (1):
      brcmfmac: avoid null pointer access when brcmf_msgbuf_get_pktid() fails

Ilan Peer (1):
      iwlwifi: pcie: fix tracking of cmd_in_flight

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-05-28' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Liad Kaufman (1):
      iwlwifi: nvm: fix otp parsing in 8000 hw family

 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c |   12 +++++------
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c     |    2 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h     |    6 +++---
 drivers/net/wireless/iwlwifi/pcie/trans.c        |    4 ++--
 drivers/net/wireless/iwlwifi/pcie/tx.c           |   23 +++++++++-------------
 5 files changed, 20 insertions(+), 27 deletions(-)

-- 
Kalle Valo
