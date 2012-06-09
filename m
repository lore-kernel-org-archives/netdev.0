From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v3 2/3] 6lowpan: fix hop limit compression
Date: Sat,  9 Jun 2012 19:13:08 +0400
Message-ID: <1339254789-10712-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Tony Cheneau <tony.cheneau+zigbeedev@amnesiak.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:43132 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab2FIPSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 11:18:53 -0400
Received: by wibhj8 with SMTP id hj8so1457071wib.1
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2012 08:18:52 -0700 (PDT)
In-Reply-To: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing pointer shift for the 'default' case.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Tony Cheneau <tony.cheneau+zigbeedev@amnesiak.org>
---
 net/ieee802154/6lowpan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 5c7bcf9..b45e229 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -492,6 +492,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 		break;
 	default:
 		*hc06_ptr = hdr->hop_limit;
+		hc06_ptr += 1;
 		break;
 	}
 
-- 
1.7.2.3
