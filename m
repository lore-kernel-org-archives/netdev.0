From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] iwl4965: drop a lone pr_err()
Date: Thu, 07 Apr 2011 20:40:32 +0200
Message-ID: <1302201632.9085.7.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

iwl4965_rate_control_register() prints a message at KERN_ERR level. It
looks like it's just a debugging message, so pr_err() seems to be
overdone. But none of the similar functions in drivers/net/wireless
print a message, so let's just drop it.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
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
1.7.4
