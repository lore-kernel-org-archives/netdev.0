From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCHv2 0/8] net: some cleanups
Date: Fri,  6 Dec 2013 10:24:01 +0800
Message-ID: <1386296649-6453-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since net-next is open now, it's time to post them out again.

Zhi Yong Wu (8):
  vhost: remove the dead branch
  vhost: adjust vhost_dev_init() to be void
  macvtap: remove the dead branch
  macvtap: adjust macvtap_skb_to_vnet_hdr() to be void
  macvtap: update file current position
  macvtap: remove unused parameter in macvtap_do_read()
  tun: update file current position
  tun: remove unused parameter in tun_do_read()

 drivers/net/macvtap.c |   16 +++++++---------
 drivers/net/tun.c     |    9 +++++----
 drivers/vhost/net.c   |    9 ++-------
 drivers/vhost/scsi.c  |    7 +------
 drivers/vhost/test.c  |    8 +-------
 drivers/vhost/vhost.c |    4 +---
 drivers/vhost/vhost.h |    2 +-
 7 files changed, 18 insertions(+), 37 deletions(-)

-- 
1.7.6.5
