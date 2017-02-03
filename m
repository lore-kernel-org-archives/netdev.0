From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net-next 0/3] net: ethernet: bgmac: PM support and clean-ups
Date: Fri,  3 Feb 2017 16:39:27 -0500
Message-ID: <1486157970-6315-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add code to support Power Management (only tested on NS2), and add some
code clean-ups

Joey Zhong (1):
  net: ethernet: bgmac: driver power manangement

Jon Mason (2):
  net: ethernet: bgmac: use #defines for MAX size
  net: ethernet: bgmac: unify code of the same family

 drivers/net/ethernet/broadcom/bgmac-bcma.c     | 64 +++++++++++---------------
 drivers/net/ethernet/broadcom/bgmac-platform.c | 34 ++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.c          | 53 +++++++++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.h          |  4 +-
 4 files changed, 118 insertions(+), 37 deletions(-)

-- 
2.7.4
