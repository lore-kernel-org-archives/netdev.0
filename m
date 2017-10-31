From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 0/3] net: dsa: lan9303: Fix STP and flooding issues
Date: Tue, 31 Oct 2017 15:47:59 +0100
Message-ID: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set finishes the STP support, and fixes flooding issues.

Patch 1 fixes a flooding issue in the previous patch set.
Patch 2 finishes STP support by adding a ALR entry.
Patch 3 prevent duplicate flooding in HW and SW bridge.


Egil Hjelmeland (3):
  net: dsa: lan9303: Transmit using ALR when unicast
  net: dsa: lan9303: Add STP ALR entry on port 0
  net: dsa: lan9303: lan9303_rcv set skb->offload_fwd_mark

 drivers/net/dsa/lan9303-core.c | 2 ++
 include/linux/dsa/lan9303.h    | 2 ++
 net/dsa/tag_lan9303.c          | 7 ++++---
 3 files changed, 8 insertions(+), 3 deletions(-)

-- 
2.11.0
