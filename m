From: Simon Horman <horms@verge.net.au>
Subject: [rfc 01/13] [RFC 01/13] netfilter: nf_conntrack_sip: Allow ct_sip_get_header() to be called with a null ct argument
Date: Thu, 05 Aug 2010 20:47:56 +0900
Message-ID: <20100805115239.689861234@vergenet.net>
References: <20100805114755.118303531@vergenet.net>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0001-netfilter-nf_conntrack_sip-Allow-ct_sip_get_header-t.patch
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/nf_conntrack_sip.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 53d8922..2fd1ea2 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -152,6 +152,9 @@ static int parse_addr(const struct nf_conn *ct, const char *cp,
 	const char *end;
 	int ret = 0;
 
+	if (!ct)
+		return 0;
+
 	memset(addr, 0, sizeof(*addr));
 	switch (nf_ct_l3num(ct)) {
 	case AF_INET:
-- 
1.7.1


