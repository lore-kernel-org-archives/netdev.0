From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum_router: Drop a redundant condition
Date: Mon,  2 Oct 2017 12:21:58 +0200
Message-ID: <20171002102158.2443-3-jiri@resnulli.us>
References: <20171002102158.2443-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36217 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751127AbdJBKWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:22:02 -0400
Received: by mail-wr0-f196.google.com with SMTP id k10so3485931wrk.3
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:22:01 -0700 (PDT)
In-Reply-To: <20171002102158.2443-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 75078a3..58bc04c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3251,7 +3251,7 @@ mlxsw_sp_fib_entry_offload_refresh(struct mlxsw_sp_fib_entry *fib_entry,
 			return;
 		if (mlxsw_sp_fib_entry_should_offload(fib_entry))
 			mlxsw_sp_fib_entry_offload_set(fib_entry);
-		else if (!mlxsw_sp_fib_entry_should_offload(fib_entry))
+		else
 			mlxsw_sp_fib_entry_offload_unset(fib_entry);
 		return;
 	default:
-- 
2.9.5
