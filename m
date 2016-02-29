From: Eric Engestrom <eric.engestrom@imgtec.com>
Subject: [PATCH] net/rtnetlink: remove dead code
Date: Mon, 29 Feb 2016 16:36:38 +0000
Message-ID: <1456763798-629-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Engestrom <eric.engestrom@imgtec.com>
To: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Thomas Graf <tgraf@suug.ch>,
	Hubert Sokolowski <hubert.sokolowski@intel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3b766cd832328fcb87db3507e7b98cf42f21689d ("net/core: Add reading VF
statistics through the PF netdevice") added that variable but it's never
been used.

Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>
---
 net/core/rtnetlink.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d735e85..35abefc 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1389,15 +1389,6 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
 	[IFLA_VF_TRUST]		= { .len = sizeof(struct ifla_vf_trust) },
 };
 
-static const struct nla_policy ifla_vf_stats_policy[IFLA_VF_STATS_MAX + 1] = {
-	[IFLA_VF_STATS_RX_PACKETS]	= { .type = NLA_U64 },
-	[IFLA_VF_STATS_TX_PACKETS]	= { .type = NLA_U64 },
-	[IFLA_VF_STATS_RX_BYTES]	= { .type = NLA_U64 },
-	[IFLA_VF_STATS_TX_BYTES]	= { .type = NLA_U64 },
-	[IFLA_VF_STATS_BROADCAST]	= { .type = NLA_U64 },
-	[IFLA_VF_STATS_MULTICAST]	= { .type = NLA_U64 },
-};
-
 static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_VF]		= { .type = NLA_U32 },
 	[IFLA_PORT_PROFILE]	= { .type = NLA_STRING,
-- 
2.7.1
