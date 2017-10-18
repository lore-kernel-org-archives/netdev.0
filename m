From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ss: Detect IPPROTO_ICMPV6 sockets
Date: Wed, 18 Oct 2017 20:08:26 +0200
Message-ID: <20171018180826.7236-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47600 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750782AbdJRSIi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 14:08:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefix IPPROTO_ICMPV6 sockets with 'icmp6' instead of '???'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index e37aba6022eb4..b5c6bbc05766e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -784,6 +784,8 @@ static const char *proto_name(int protocol)
 		return "sctp";
 	case IPPROTO_DCCP:
 		return "dccp";
+	case IPPROTO_ICMPV6:
+		return "icmp6";
 	}
 
 	return "???";
-- 
2.13.1
