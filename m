From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers 2017-06-06
Date: Tue, 06 Jun 2017 15:20:20 +0300
Message-ID: <8760g95muz.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36078 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751433AbdFFMU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:20:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

fixes to net tree, more info in the tag below. Please let me know if
there are any problems.

Kalle

The following changes since commit 6d18c732b95c0a9d35e9f978b4438bba15412284:

  bridge: start hello_timer when enabling KERNEL_STP in br_stp_start (2017-05-21 13:33:28 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git tags/wireless-drivers-for-davem-2017-06-06

for you to fetch changes up to dc89481bb4c9af0700423e21c8371379d3d943b1:

  Merge tag 'iwlwifi-for-kalle-2017-06-05' of git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes (2017-06-05 22:21:25 +0300)

----------------------------------------------------------------
wireless-drivers fixes for 4.12

It has been a slow start of cycle and this the first set of fixes for
4.12. Nothing really major here.

wcn36xx

* fix an issue with module reload

brcmfmac

* fix aligment regression on 64 bit systems

iwlwifi

* fixes for memory leaks, runtime PM, memory initialisation and other
  smaller problems

* fix IBSS on devices using DQA mode (7260 and up)

* fix the minimum firmware API requirement for 7265D, 3168, 8000 and
  8265

----------------------------------------------------------------
Arend Van Spriel (1):
      brcmfmac: fix alignment configuration on host using 64-bit DMA

Bjorn Andersson (1):
      wcn36xx: Close SMD channel on device removal

Emmanuel Grumbach (1):
      iwlwifi: mvm: fix firmware debug restart recording

Gregory Greenman (1):
      iwlwifi: mvm: rs: start using LQ command color

Haim Dreyfuss (1):
      iwlwifi: mvm: Fix command queue number on d0i3 flow

Johannes Berg (2):
      iwlwifi: tt: move ucode_loaded check under mutex
      iwlwifi: mvm: clear new beacon command template struct

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-06-05' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Liad Kaufman (1):
      iwlwifi: mvm: support ibss in dqa mode

Luca Coelho (3):
      iwlwifi: pcie: only use d0i3 in suspend/resume if system_pm is set to d0i3
      iwlwifi: mvm: don't fail when removing a key from an inexisting sta
      iwlwifi: fix min API version for 7265D, 3168, 8000 and 8265

Shahar S Matityahu (1):
      iwlwifi: fix host command memory leaks

 drivers/net/wireless/ath/wcn36xx/main.c            |  2 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |  4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |  4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |  1 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h |  5 +++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |  3 ++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    | 12 +-----
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |  2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |  6 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       | 32 +++++++++++----
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        | 46 ++++++----------------
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h        | 15 +++++++
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       | 26 +++++++-----
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |  2 +
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |  8 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        | 12 +++++-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  6 ++-
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c  |  9 +++--
 19 files changed, 118 insertions(+), 79 deletions(-)
