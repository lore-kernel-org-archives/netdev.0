From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/5] tc: man: add limit parameter to tc-sfq man page
Date: Tue, 12 Jan 2010 21:39:12 +0100
Message-ID: <1263328756-19431-1-git-send-email-fw@strlen.de>
References: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Cc: shemminger@vyatta.com, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51028 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab0ALUj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:39:57 -0500
In-Reply-To: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 man/man8/tc-sfq.8 |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/man8/tc-sfq.8 b/man/man8/tc-sfq.8
index 337c795..8f2b433 100644
--- a/man/man8/tc-sfq.8
+++ b/man/man8/tc-sfq.8
@@ -51,6 +51,9 @@ on the fullest bucket, thus maintaining fairness.
 
 .SH PARAMETERS
 .TP 
+limit
+Upper limit of the SFQ. Can be used to reduce the default length of 128 packets.
+.TP
 perturb
 Interval in seconds for queue algorithm perturbation. Defaults to 0, which means that 
 no perturbation occurs. Do not set too low for each perturbation may cause some packet
-- 
1.6.4.4

