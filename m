From: Karol Herbst <git@karolherbst.de>
Subject: [PATCH 0/2] drivers/net/forcedeth: add support for WAKE_PHY
Date: Thu, 10 Mar 2016 15:58:02 +0100
Message-ID: <1457621884-2479-1-git-send-email-git@karolherbst.de>
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Karol Herbst <nouveau@karolherbst.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karol Herbst <nouveau@karolherbst.de>

I want to use my mac mini as a local server, but put it to sleep automatically
therefore wol p, and because wol g is a mess if you want to wakeup the target
machine automagically :)

Karol Herbst (2):
  net/forcedeth: refactor wol support to make it easier adding more
    modes
  net/forcedeth: add wol p support

 drivers/net/ethernet/nvidia/forcedeth.c | 37 ++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 14 deletions(-)

-- 
2.7.2
