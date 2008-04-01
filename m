From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] SCTP: Remove useless assignment from __sctp_rcv_lookup_endpoint
Date: Tue, 01 Apr 2008 14:11:28 +0800
Message-ID: <47F1D210.9070209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>,
	vladislav <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55975 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbYDAGMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 02:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove useless assignment from __sctp_rcv_lookup_endpoint

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 net/sctp/input.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 812ff17..1878d82 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -725,7 +725,6 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(const union sctp_addr *l
 	}
 
 	ep = sctp_sk((sctp_get_ctl_sock()))->ep;
-	epb = &ep->base;
 
 hit:
 	sctp_endpoint_hold(ep);
-- 
1.5.3


