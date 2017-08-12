From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 13/51] iproute_lwtunnel: Argument to strerror must be positive
Date: Sat, 12 Aug 2017 14:04:32 +0200
Message-ID: <20170812120510.28750-14-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34047 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752533AbdHLMGi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:38 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute_lwtunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 398ab5e077ed8..1a3dc4d4c0ed9 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -643,7 +643,7 @@ static int lwt_parse_bpf(struct rtattr *rta, size_t len,
 	err = bpf_parse_common(bpf_type, &cfg, &bpf_cb_ops, &x);
 	if (err < 0) {
 		fprintf(stderr, "Failed to parse eBPF program: %s\n",
-			strerror(err));
+			strerror(-err));
 		return -1;
 	}
 	rta_nest_end(rta, nest);
-- 
2.13.1
