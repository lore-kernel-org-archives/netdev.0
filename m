From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH] checkpatch: add double empty line check
Date: Fri, 16 Nov 2012 21:41:59 +0200
Message-ID: <1353094919.14327.4.camel@lb-tlvb-eilong.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Joe Perches" <joe@perches.com>, netdev <netdev@vger.kernel.org>
To: "Andy Whitcroft" <apw@canonical.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 scripts/checkpatch.pl |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 21a9f5d..7a9c153 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3579,6 +3579,13 @@ sub process {
 			WARN("EXPORTED_WORLD_WRITABLE",
 			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
 		}
+
+# check for double empty lines
+		if ($line =~ /^\+\s*$/ &&
+		    ($prevline =~ /^\+?\s*$/ || $rawlines[$linenr] =~ /^\s*$/)) {
+			WARN("DOUBLE_EMPTY_LINE",
+			     "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
+		}
 	}
 
 	# If we have no input at all, then there is nothing to report on
-- 
1.7.9.5
