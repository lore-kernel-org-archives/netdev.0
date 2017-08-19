From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 0/5] constify net eisa_device_id
Date: Sat, 19 Aug 2017 12:21:42 +0530
Message-ID: <1503125503-15075-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eisa_device_id are not supposed to change at runtime. All functions
working with eisa_device_id provided by <linux/eisa.h> work with
const eisa_device_id. So mark the non-const structs as const.

Arvind Yadav (5):
  [PATCH 1/5] net: 3c509: constify eisa_device_id
  [PATCH 2/5] net: 3c59x: constify eisa_device_id
  [PATCH 3/5] net: de4x5: constify eisa_device_id
  [PATCH 4/5] net: hp100: constify eisa_device_id
  [PATCH 5/5] net: defxx: constify eisa_device_id

 drivers/net/ethernet/3com/3c509.c      | 2 +-
 drivers/net/ethernet/3com/3c59x.c      | 2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c | 2 +-
 drivers/net/ethernet/hp/hp100.c        | 2 +-
 drivers/net/fddi/defxx.c               | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

-- 
2.7.4
