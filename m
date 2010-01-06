From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] net/ipv4/netfilter/nf_nat_ftp.c: Convert NIPQUAD to %pI4
Date: Tue,  5 Jan 2010 17:20:17 -0800
Message-ID: <bccf36219f3ea5a9b7565734bc87095bc986dbe0.1262726222.git.joe@perches.com>
References: <cover.1262726222.git.joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1535 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755386Ab0AFBU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 20:20:26 -0500
In-Reply-To: <cover.1262726222.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/netfilter/nf_nat_ftp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
index a1d5d58..d1c5afc 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/ipv4/netfilter/nf_nat_ftp.c
@@ -59,7 +59,7 @@ mangle_eprt_packet(struct sk_buff *skb,
 {
 	char buffer[sizeof("|1|255.255.255.255|65535|")];
 
-	sprintf(buffer, "|1|%u.%u.%u.%u|%u|", NIPQUAD(newip), port);
+	sprintf(buffer, "|1|%pI4|%u|", &newip, port);
 
 	pr_debug("calling nf_nat_mangle_tcp_packet\n");
 
-- 
1.6.6.rc0.57.gad7a

