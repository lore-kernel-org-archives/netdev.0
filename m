From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: spectrum: mr_tcam: Include the mr_tcam header file
Date: Tue, 24 Oct 2017 11:17:17 +0200
Message-ID: <20171024091717.1180-4-jiri@resnulli.us>
References: <20171024091717.1180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56762 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751870AbdJXJRW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:17:22 -0400
Received: by mail-wm0-f66.google.com with SMTP id z3so7824281wme.5
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:17:22 -0700 (PDT)
In-Reply-To: <20171024091717.1180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Make the spectrum_mr_tcam.c include the spectrum_mr_tcam.h header file.

Cleans up sparse warning:
symbol 'mlxsw_sp_mr_tcam_ops' was not declared. Should it be static?

Fixes: 0e14c7777acb6 ("mlxsw: spectrum: Add the multicast routing hardware logic")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
index 39c21c7..34a0b63 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
@@ -37,6 +37,7 @@
 #include <linux/netdevice.h>
 #include <linux/parman.h>
 
+#include "spectrum_mr_tcam.h"
 #include "reg.h"
 #include "spectrum.h"
 #include "core_acl_flex_actions.h"
-- 
2.9.5
