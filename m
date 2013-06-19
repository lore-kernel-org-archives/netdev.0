From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] checkpatch: modify logFunction regular expression to allow repeated front tags
Date: Wed, 19 Jun 2013 03:38:43 -0700
Message-ID: <1371638323-20999-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: apw@canonical.com, joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jacob Keller <jacob.e.keller@intel.com>

The previous logFunction regular expression allowed names for log functions like
dev_warn or e_dbg and so forth, but some log functions are of the forms
similar to e_dev_warn, (adding an additional tag in front of a standard name
like dev_warn).

This patch modifies checkpatch to enable use of this type of log function name.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index b954de5..a38d71e 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -269,7 +269,7 @@ our $typeTypedefs = qr{(?x:
 
 our $logFunctions = qr{(?x:
 	printk(?:_ratelimited|_once|)|
-	[a-z0-9]+_(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
+	(?:[a-z0-9]+_)+(?:printk|emerg|alert|crit|err|warning|warn|notice|info|debug|dbg|vdbg|devel|cont|WARN)(?:_ratelimited|_once|)|
 	WARN(?:_RATELIMIT|_ONCE|)|
 	panic|
 	MODULE_[A-Z_]+
-- 
1.7.11.7
