From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: reg: Fix pwm_frequency field size in MFCR register
Date: Fri, 11 Nov 2016 11:22:53 +0100
Message-ID: <1478859773-3013-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36017 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcKKKXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 05:23:01 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so6741188wma.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 02:22:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The field is 7bit long. Fix it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0936b4a..b5ab81a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4424,7 +4424,7 @@ enum mlxsw_reg_mfcr_pwm_frequency {
  * Controls the frequency of the PWM signal.
  * Access: RW
  */
-MLXSW_ITEM32(reg, mfcr, pwm_frequency, 0x00, 0, 6);
+MLXSW_ITEM32(reg, mfcr, pwm_frequency, 0x00, 0, 7);
 
 #define MLXSW_MFCR_TACHOS_MAX 10
 
-- 
2.7.4
