From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 1/2] tc/cls_flower: Add to the usage encapsulation dest UDP port
Date: Thu, 22 Dec 2016 10:14:40 +0200
Message-ID: <1482394481-19624-2-git-send-email-hadarh@mellanox.com>
References: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34901 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1765112AbcLVJK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 04:10:26 -0500
In-Reply-To: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Encapsulation dest UDP port is part of the classifier matching
parameters, add it to the usage.

Fixes: 41aa17ff4668 ("tc/cls_flower: Add dest UDP port to tunnel params")
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reported-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 653dfef..71e9515 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -53,10 +53,11 @@ static void explain(void)
 		"                       dst_port PORT-NUMBER |\n"
 		"                       src_port PORT-NUMBER |\n"
 		"                       type ICMP-TYPE |\n"
-		"                       code ICMP-CODE }\n"
+		"                       code ICMP-CODE |\n"
 		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
-		"                       enc_key_id [ KEY-ID ] }\n"
+		"                       enc_key_id [ KEY-ID ] |\n"
+		"                       enc_dst_port [ UDP-PORT ] }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
 		"\n"
-- 
1.8.3.1
