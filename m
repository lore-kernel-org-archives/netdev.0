From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH v4 net-next 0/4] net: some cleanups
Date: Sat,  7 Dec 2013 04:13:02 +0800
Message-ID: <1386360786-17687-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since net-next is open now, it's time to post them out again.

Changelog from v3:
 -combine the change that removes the return value check with
the change which adjusts the function return type to "void". [David Miller]

Zhi Yong Wu (4):
  vhost: remove the dead branch
  macvtap: remove the dead branch
  macvtap: remove unused parameter in macvtap_do_read()
  tun: remove unused parameter in tun_do_read()

 drivers/net/macvtap.c |   14 +++++---------
 drivers/net/tun.c     |    7 +++----
 drivers/vhost/net.c   |    9 ++-------
 drivers/vhost/scsi.c  |    7 +------
 drivers/vhost/test.c  |    8 +-------
 drivers/vhost/vhost.c |    4 +---
 drivers/vhost/vhost.h |    2 +-
 7 files changed, 14 insertions(+), 37 deletions(-)

-- 
1.7.6.5
