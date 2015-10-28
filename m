From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/12] mlxsw: Put braces on all arms of branch statement
Date: Wed, 28 Oct 2015 10:17:04 +0100
Message-ID: <1446023825-7162-12-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36035 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932551AbbJ1JZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:25:10 -0400
Received: by wmec75 with SMTP id c75so5291443wme.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:25:09 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fix a place where checkpatch complains that braces should be used
on all arms of this statement.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 371ea3f..de69e71 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1662,8 +1662,9 @@ static int mlxsw_pci_cmd_exec(void *bus_priv, u16 opcode, u8 opcode_mod,
 							   CIR_OUT_PARAM_LO));
 			memcpy(out_mbox + sizeof(tmp), &tmp, sizeof(tmp));
 		}
-	} else if (!err && out_mbox)
+	} else if (!err && out_mbox) {
 		memcpy(out_mbox, mlxsw_pci->cmd.out_mbox.buf, out_mbox_size);
+	}
 
 	mutex_unlock(&mlxsw_pci->cmd.lock);
 
-- 
1.9.3
