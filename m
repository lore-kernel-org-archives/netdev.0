From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] net: mpls: make function ipgre_mpls_encap_hlen static
Date: Wed, 11 Oct 2017 10:53:28 +0100
Message-ID: <20171011095328.17546-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsahern@gmail.com>,
        Robert Shearman <rshearma@brocade.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The function ipgre_mpls_encap_hlen is local to the source and
does not need to be in global scope, so make it static.

Cleans up sparse warning:
symbol 'ipgre_mpls_encap_hlen' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 9745e8f69810..8ca9915befc8 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -41,7 +41,7 @@ static int label_limit = (1 << 20) - 1;
 static int ttl_max = 255;
 
 #if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
-size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
+static size_t ipgre_mpls_encap_hlen(struct ip_tunnel_encap *e)
 {
 	return sizeof(struct mpls_shim_hdr);
 }
-- 
2.14.1
