From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 07/12] ip6tunnel: fix coding style: no newline between brace and else
Date: Fri, 13 Nov 2015 18:09:00 +0100
Message-ID: <1447434545-32182-8-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53720 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933415AbbKMRJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:11 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 9eb5b2f..d8957f0 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -262,8 +262,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 		} else {
 			if (strcmp(*argv, "name") == 0) {
 				NEXT_ARG();
-			}
-			else if (matches(*argv, "help") == 0)
+			} else if (matches(*argv, "help") == 0)
 				usage();
 			if (p->name[0])
 				duparg2("name", *argv);
-- 
2.1.2
