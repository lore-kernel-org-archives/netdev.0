From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH iproute2] ipnetns: fixed typo "seting" -> "setTing"
Date: Sun, 22 Jun 2014 23:11:28 +0400
Message-ID: <53A72A60.5080708@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:40597 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041AbaFVTMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jun 2014 15:12:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vasily Averin <vvs@openvz.org>
---
 ip/ipnetns.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 2b3b2e1..633b5b9 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -158,7 +158,7 @@ static int netns_exec(int argc, char **argv)
 	}
 
 	if (setns(netns, CLONE_NEWNET) < 0) {
-		fprintf(stderr, "seting the network namespace \"%s\" failed: %s\n",
+		fprintf(stderr, "setting the network namespace \"%s\" failed: %s\n",
 			name, strerror(errno));
 		return -1;
 	}
-- 
1.7.5.4
