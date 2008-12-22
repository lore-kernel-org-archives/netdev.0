From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 21 Dec 2008 19:49:17 -0800 (PST)
Message-ID: <20081221.194917.45190672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cc@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49920
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752142AbYLVDtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 22:49:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull to get these two bug fixes:

1) PPP device unregister crash regression.  Fix from
   James Chapman.

2) kernel_accept() socket module refcounting is bolixed,
   fix from Wei Yongjun.

Thanks!

The following changes since commit 3298a7388c00227e736d1037328788073c80c7b4:
  Michael Chan (1):
        bnx2: Fix bug in bnx2_free_rx_mem().

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

James Chapman (1):
      ppp: fix segfaults introduced by netdev_priv changes

Wei Yongjun (1):
      net: Fix module refcount leak in kernel_accept()

 drivers/net/ppp_generic.c   |   28 +++++++++++++---------------
 net/bluetooth/rfcomm/core.c |    2 --
 net/socket.c                |    1 +
 3 files changed, 14 insertions(+), 17 deletions(-)
