From: John Crispin <john@phrozen.org>
Subject: [PATCH 0/4] net-next: dsa: set_addr should be optional
Date: Mon, 19 Sep 2016 15:27:59 +0200
Message-ID: <1474291683-44167-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell driver is the only one that actually sets the switches HW
address. All other drivers have an empty stub. fix this by making the
callback optional.

John Crispin (4):
  net-next: dsa: fix duplicate invocation of set_addr()
  net-next: dsa: make the set_addr() operation optional
  net-next: dsa: b53: remove empty set_addr() stub
  net-next: dsa: qca8k: remove empty set_addr() stub

 drivers/net/dsa/b53/b53_common.c |    6 ------
 drivers/net/dsa/qca8k.c          |    8 --------
 net/dsa/dsa.c                    |    8 +++++---
 net/dsa/dsa2.c                   |   12 +++++-------
 4 files changed, 10 insertions(+), 24 deletions(-)

-- 
1.7.10.4
