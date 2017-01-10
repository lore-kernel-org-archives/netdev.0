From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 06/10] net/mlx5e: Fix kbuild warnings for uninitialized parameters
Date: Tue, 10 Jan 2017 22:33:35 +0200
Message-ID: <1484080419-24256-7-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52064 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751117AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

kbuild warn about parameters that may be used uninitialized, fix it.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index a35fa1e..5dbc81d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -737,8 +737,8 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	struct flowi4 fl4 = {};
 	char *encap_header;
 	int encap_size;
-	__be32 saddr;
-	int ttl;
+	__be32 saddr = 0;
+	int ttl = 0;
 	int err;
 
 	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
-- 
2.7.4
