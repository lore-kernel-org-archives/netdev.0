From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 0/3] constify dsa_switch_ops
Date: Wed, 23 Aug 2017 15:46:56 +0530
Message-ID: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dsa_switch_ops are not supposed to change at runtime. All functions
working with dsa_switch_ops provided by <net/dsa.h> work with
const dsa_switch_ops. So mark the non-const structs as const.

Arvind Yadav (3):
  [PATCH 1/3] net: dsa: loop: constify dsa_switch_ops
  [PATCH 2/3] net: dsa: lan9303: constify dsa_switch_ops
  [PATCH 3/3] net: dsa: mt7530: constify dsa_switch_ops

 drivers/net/dsa/dsa_loop.c     | 2 +-
 drivers/net/dsa/lan9303-core.c | 2 +-
 drivers/net/dsa/mt7530.c       | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

-- 
1.9.1
