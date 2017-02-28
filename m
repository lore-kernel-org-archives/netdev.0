From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net v4 0/2] net: ethernet: bgmac: bug fixes
Date: Tue, 28 Feb 2017 13:41:49 -0500
Message-ID: <1488307311-11933-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes in v4:
* Added the udelays from the previous code (per David Miller)

Changes in v3:
* Reworked the init sequence patch to only remove the device reset if
  the device is actually in reset.  Given that this code doesn't bear
  much resemblance to the original code, I'm changing the author of the
  patch.  This was tested on NS2 SVK.

Changes in v2:
* Reworked the first match to make it more obvious what portions of the
  register were being preserved (Per Rafal Mileki)
* Style change to reorder the function variables in patch 2 (per Sergei
  Shtylyov)


Bug fixes for bgmac driver


Hari Vyas (1):
  net: ethernet: bgmac: mac address change bug

Jon Mason (1):
  net: ethernet: bgmac: init sequence bug

 drivers/net/ethernet/broadcom/bgmac-platform.c | 27 +++++++++++++++++---------
 drivers/net/ethernet/broadcom/bgmac.c          |  6 +++++-
 drivers/net/ethernet/broadcom/bgmac.h          | 16 +++++++++++++++
 3 files changed, 39 insertions(+), 10 deletions(-)

-- 
2.7.4
