From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v3 3/4] checkpatch: Fix processing of MEMSET issues
Date: Sun, 26 Apr 2015 18:43:19 +0200
Message-ID: <1430066600-12210-4-git-send-email-mateusz.kulikowski@gmail.com>
References: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:34451 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbbDZQnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 12:43:35 -0400
In-Reply-To: <1430066600-12210-1-git-send-email-mateusz.kulikowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove 's' modifier to avoid reporting the same warning several times.

Signed-off-by: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 263e831..c05befe 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5010,7 +5010,7 @@ sub process {
 # Check for misused memsets
 		if ($^V && $^V ge 5.10.0 &&
 		    defined $stat &&
-		    $stat =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*$FuncArg\s*\)/s) {
+		    $stat =~ /^\+(?:.*?)\bmemset\s*\(\s*$FuncArg\s*,\s*$FuncArg\s*\,\s*$FuncArg\s*\)/) {
 
 			my $ms_addr = $2;
 			my $ms_val = $7;
-- 
1.8.4.1
