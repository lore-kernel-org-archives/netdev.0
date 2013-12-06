From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCH v3 0/6] net: some cleanups
Date: Fri,  6 Dec 2013 14:19:36 +0800
Message-ID: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since net-next is open now, it's time to post them again.

Zhi Yong Wu (6):
  vhost: remove the dead branch
  vhost: adjust vhost_dev_init() to be void
  macvtap: remove the dead branch
  macvtap: adjust macvtap_skb_to_vnet_hdr() to be void
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
