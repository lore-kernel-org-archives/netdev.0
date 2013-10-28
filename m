From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH v2 2/3] net, datagram: fix the incorrect comment in zerocopy_sg_from_iovec()
Date: Mon, 28 Oct 2013 14:01:49 +0800
Message-ID: <1382940110-10737-2-git-send-email-zwu.kernel@gmail.com>
References: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382940110-10737-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/datagram.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index af814e7..a16ed7b 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -577,7 +577,7 @@ EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
 /**
  *	zerocopy_sg_from_iovec - Build a zerocopy datagram from an iovec
  *	@skb: buffer to copy
- *	@from: io vector to copy to
+ *	@from: io vector to copy from
  *	@offset: offset in the io vector to start copying from
  *	@count: amount of vectors to copy to buffer from
  *
-- 
1.7.11.7
