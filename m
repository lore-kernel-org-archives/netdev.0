From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH net-next] tcp: silence registration message
Date: Mon, 16 Feb 2015 09:38:13 -0500
Message-ID: <20150216093813.2d83e47c@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:12634 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755397AbbBPOiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 09:38:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message isn't really needed it justs waits time/space.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 net/ipv4/tcp_cong.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv4/tcp_cong.c	2015-02-16 09:11:25.714980610 -0500
+++ b/net/ipv4/tcp_cong.c	2015-02-16 09:11:25.710980555 -0500
@@ -83,7 +83,7 @@ int tcp_register_congestion_control(stru
 		ret = -EEXIST;
 	} else {
 		list_add_tail_rcu(&ca->list, &tcp_cong_list);
-		pr_info("%s registered\n", ca->name);
+		pr_debug("%s registered\n", ca->name);
 	}
 	spin_unlock(&tcp_cong_list_lock);
 
