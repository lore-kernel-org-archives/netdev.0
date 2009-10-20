From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH RFC] Document future removal of sysctl_tcp_* options
Date: Tue, 20 Oct 2009 17:22:41 +0200
Message-ID: <1256052161-14156-9-git-send-email-gilad@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
 <1256052161-14156-2-git-send-email-gilad@codefidence.com>
 <1256052161-14156-3-git-send-email-gilad@codefidence.com>
 <1256052161-14156-4-git-send-email-gilad@codefidence.com>
 <1256052161-14156-5-git-send-email-gilad@codefidence.com>
 <1256052161-14156-6-git-send-email-gilad@codefidence.com>
 <1256052161-14156-7-git-send-email-gilad@codefidence.com>
 <1256052161-14156-8-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37458 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbZJTPWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 11:22:42 -0400
In-Reply-To: <1256052161-14156-8-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for global kill switches if we have per route entry controls.
Wait a year before removing in case someone is using this.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>

---
 Documentation/feature-removal-schedule.txt |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 89a47b5..60db855 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -6,6 +6,18 @@ be removed from this file.
 
 ---------------------------
 
+What:	sysctl_tcp_sack, sysctl_tcp_timestamps, sysctl_tcp_window_scaling,
+	sysctl_tcp_dsack
+When:	October 2010
+
+Why:	These options can now be set on a per route basis via the
+	RTAX_FEATURE_NO_SACK, RTAX_FEATURE_NO_TSTAMP, RTAX_FEATURE_NO_WSCALE,
+	and RTAX_FEATURE_NO_DSACK route feature options.
+
+Who:	Gilad Ben-Yossef <gilad@codefidence.com>
+
+---------------------------
+
 What:	PRISM54
 When:	2.6.34
 
-- 
1.5.6.3

