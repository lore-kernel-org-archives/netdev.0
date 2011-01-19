From: kaber@trash.net
Subject: [PATCH 65/79] audit: export symbol for use with xt_AUDIT
Date: Wed, 19 Jan 2011 20:15:05 +0100
Message-ID: <1295464519-21763-66-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52009 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab1ASTPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:40 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

When xt_AUDIT is built as a module, modpost reports a problem.

	MODPOST 322 modules
	ERROR: "audit_enabled" [net/netfilter/x_tables.ko] undefined!
	WARNING: modpost: Found 1 section mismatch(es).

Cc: Thomas Graf <tgraf@redhat.com>
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 kernel/audit.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 77770a0..5842f65 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -74,6 +74,8 @@ static int	audit_initialized;
 int		audit_enabled;
 int		audit_ever_enabled;
 
+EXPORT_SYMBOL_GPL(audit_enabled);
+
 /* Default state when kernel boots without any parameters. */
 static int	audit_default;
 
-- 
1.7.2.3

