From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCH 0/6] some cleanups
Date: Fri,  6 Dec 2013 06:28:41 +0800
Message-ID: <1386282527-14094-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:33522 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205Ab3LEW27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 17:28:59 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Thu, 5 Dec 2013 15:28:58 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since net-next is open now, it's time to post them out again.

Zhi Yong Wu (6):
  vhost: remove the dead branch
  vhost: adjust vhost_dev_init() to be void
  macvtap: remove the dead branch
  macvtap: adjust macvtap_skb_to_vnet_hdr() to be void
  macvtap: update file current position
  macvtap: remove unused paramter in macvtap_do_read()

 drivers/net/macvtap.c |   16 +++++++---------
 drivers/vhost/net.c   |    9 ++-------
 drivers/vhost/scsi.c  |    7 +------
 drivers/vhost/test.c  |    8 +-------
 drivers/vhost/vhost.c |    4 +---
 drivers/vhost/vhost.h |    2 +-
 6 files changed, 13 insertions(+), 33 deletions(-)

-- 
1.7.6.5
