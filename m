From: Colin King <colin.king@canonical.com>
Subject: [PATCH] tcp: cdg: make struct tcp_cdg static
Date: Mon, 16 Oct 2017 14:33:21 +0100
Message-ID: <20171016133321.15477-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The structure tcp_cdg is local to the source and
does not need to be in global scope, so make it static.

Cleans up sparse warning:
symbol 'tcp_cdg' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv4/tcp_cdg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index 66ac69f7bd19..06fbe102a425 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -389,7 +389,7 @@ static void tcp_cdg_release(struct sock *sk)
 	kfree(ca->gradients);
 }
 
-struct tcp_congestion_ops tcp_cdg __read_mostly = {
+static struct tcp_congestion_ops tcp_cdg __read_mostly = {
 	.cong_avoid = tcp_cdg_cong_avoid,
 	.cwnd_event = tcp_cdg_cwnd_event,
 	.pkts_acked = tcp_cdg_acked,
-- 
2.14.1
