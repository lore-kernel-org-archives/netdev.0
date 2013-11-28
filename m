From: Ondrej Puzman <puzman@gmail.com>
Subject: [PATCH 0/4] pch_gbe fixes and enhancements
Date: Thu, 28 Nov 2013 10:44:38 +0100
Message-ID: <1385631882-12827-1-git-send-email-puzman@gmail.com>
References: <20131127.203929.1379316258754767343.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ondrej Puzman <puzman@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131127.203929.1379316258754767343.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I'm sending the pch_gbe patch set again per David Miller's request.
Now the patches should be correctly numbered.

The patches fixes problems I found on our industrial computer with Intel Atom E680T CPU and EG20T chipset.

Ondrej Puzman (4):
  pch_gbe: Fix transmit queue management
  pch_gbe: Remove tx_queue_len setting from the driver
  pch_gbe: Add DQL support to the driver
  pch_gbe: Fix: Link configuration in module parameters was ignored

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    2 --
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |    4 ----
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   18 +++++++++++++-----
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    |   13 +------------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |    1 -
 5 files changed, 14 insertions(+), 24 deletions(-)

-- 
1.7.2.3
