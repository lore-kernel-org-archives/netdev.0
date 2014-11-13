From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH 0/2] Fix sleeping function called from invalid context
Date: Thu, 13 Nov 2014 16:02:13 +0900
Message-ID: <1415862135-27972-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is based on net tree.

Mitsuhiro Kimura (2):
  sh_eth: Fix sleeping function called from invalid context
  sh_eth: Fix asynchronous external abort

 drivers/net/ethernet/renesas/sh_eth.c | 70 ++++++++++++++++++++---------------
 drivers/net/ethernet/renesas/sh_eth.h |  1 +
 2 files changed, 42 insertions(+), 29 deletions(-)

-- 
1.9.1

