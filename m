From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/5] tc: man: SO_PRIORITY is described in socket documentation, not tc one
Date: Tue, 12 Jan 2010 21:43:19 +0100
Message-ID: <1263329002-19564-1-git-send-email-fw@strlen.de>
References: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Cc: shemminger@vyatta.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54386 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751808Ab0ALUoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:44:04 -0500
In-Reply-To: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix up reference: there is no tc(7) man page.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 man/man8/tc-prio.8 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/man8/tc-prio.8 b/man/man8/tc-prio.8
index 780bcd5..1625fcc 100644
--- a/man/man8/tc-prio.8
+++ b/man/man8/tc-prio.8
@@ -50,7 +50,7 @@ be enqueued.
 From userspace
 A process with sufficient privileges can encode the destination class
 directly with SO_PRIORITY, see
-.BR tc(7).
+.BR socket(7).
 .TP 
 with a tc filter
 A tc filter attached to the root qdisc can point traffic directly to a class
-- 
1.6.4.4

