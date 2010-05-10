From: kaber@trash.net
Subject: [PATCH 10/84] netfilter: xtables: schedule xt_NOTRACK for removal
Date: Mon, 10 May 2010 22:17:41 +0200
Message-ID: <1273522735-24672-11-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

It is being superseded by xt_CT (-j CT --notrack).

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 Documentation/feature-removal-schedule.txt |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index ed511af..8843fef 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -589,3 +589,11 @@ Why:	Useful in 2003, implementation is a hack.
 	Generally invoked by accident today.
 	Seen as doing more harm than good.
 Who:	Len Brown <len.brown@intel.com>
+
+---------------------------
+
+What:	xt_NOTRACK
+Files:	net/netfilter/xt_NOTRACK.c
+When:	April 2011
+Why:	Superseded by xt_CT
+Who:	Netfilter developer team <netfilter-devel@vger.kernel.org>
-- 
1.7.0.4

