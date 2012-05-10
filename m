From: alex.bluesman.smirnov@gmail.com
Subject: [PATCH 2/2 net] 6lowpan: fix hop limit compression
Date: Thu, 10 May 2012 17:22:43 +0400
Message-ID: <4fabc167.9208cc0a.4de8.ffff9218@mx.google.com>
References: <1336656163-19382-1-git-send-email-y>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Tony Cheneau <tony.cheneau+zigbeedev@amnesiak.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50814 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab2EJNXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 09:23:53 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so1280917bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 06:23:52 -0700 (PDT)
In-Reply-To: <1336656163-19382-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Add missing pointer shift for the 'default' case.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Tony Cheneau <tony.cheneau+zigbeedev@amnesiak.org>
---
 net/ieee802154/6lowpan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 0ab3efe..86f0013 100644
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
