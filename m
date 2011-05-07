From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] [RESEND] iwl4965: drop a lone pr_err()
Date: Sat, 07 May 2011 14:31:59 +0200
Message-ID: <1304771519.2227.6.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:40518 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091Ab1EGMcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 08:32:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iwl4965_rate_control_register() prints a message at KERN_ERR level. It
looks like it's just a debugging message, so pr_err() seems to be
overdone. But none of the similar functions in drivers/net/wireless
print a message, so let's just drop it entirely.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Previously sent for (I guess) v2.6.39-rc2. Still present in v2.6.39-rc6.

 drivers/net/wireless/iwlegacy/iwl-4965-rs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
index 31ac672..8950939 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
@@ -2860,7 +2860,6 @@ static struct rate_control_ops rs_4965_ops = {
 
 int iwl4965_rate_control_register(void)
 {
-	pr_err("Registering 4965 rate control operations\n");
 	return ieee80211_rate_control_register(&rs_4965_ops);
 }
 
-- 
1.7.4.4



