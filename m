From: Alexander Graf <sohalt@gmail.com>
Subject: [PATCH] [iputils] Print received packets as icmp_seq
Date: Tue,  7 Aug 2007 15:49:49 +0200
Message-ID: <1186494590225-git-send-email-sohalt@gmail.com>
Cc: Alexander Graf <sohalt@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:26600 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352AbXHGNtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 09:49:55 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1679257fkz
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2007 06:49:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now, ping and ping6 print the packets which are actually received, too, not
only the amount of sent packets.

It has the format:
icmp_seq=received/seq

Signed-off-by: Alexander Graf <sohalt@gmail.com>
---
 ping_common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ping_common.c b/ping_common.c
index be36cbd..83be553 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -711,7 +711,7 @@ restamp:
 	} else {
 		int i;
 		__u8 *cp, *dp;
-		printf("%d bytes from %s: icmp_seq=%u", cc, from, seq);
+		printf("%d bytes from %s: icmp_seq=%li/%u", cc, from, nreceived, seq);
 
 		if (hops >= 0)
 			printf(" ttl=%d", hops);
-- 
1.5.2.4


