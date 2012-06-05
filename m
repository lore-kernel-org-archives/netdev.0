From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH IPROUTE2 V2] tc: Update manpage
Date: Tue,  5 Jun 2012 11:41:26 -0700
Message-ID: <1338921686-10372-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	jan.ceuleers@computer.org,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58912 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755849Ab2FESiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 14:38:17 -0400
Received: by dady13 with SMTP id y13so7657814dad.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 11:38:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes 2 changes:
1: Add fq_codel to SEE ALSO section in tc manpage.
2: Reorder the SEE ALSO section to make the order alphabetical
(suggested by Jan Ceuleers ).

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 V2: Reorder the SEE ALSO section to make it alphabetical.

 man/man8/tc.8 |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 14a1cd8..958ab98 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -366,21 +366,22 @@ print rates in IEC units (ie. 1K = 1024).
 .B tc
 was written by Alexey N. Kuznetsov and added in Linux 2.2.
 .SH SEE ALSO
+.BR tc-bfifo (8),
 .BR tc-cbq (8),
 .BR tc-choke (8),
 .BR tc-codel (8),
 .BR tc-drr (8),
-.BR tc-htb (8),
-.BR tc-hfsc (8),
+.BR tc-fq_codel (8),
 .BR tc-hfsc (7),
-.BR tc-sfb (8),
-.BR tc-sfq (8),
-.BR tc-red (8),
-.BR tc-tbf (8),
+.BR tc-hfsc (8),
+.BR tc-htb (8),
 .BR tc-pfifo (8),
-.BR tc-bfifo (8),
 .BR tc-pfifo_fast (8),
+.BR tc-red (8),
+.BR tc-sfb (8),
+.BR tc-sfq (8),
 .BR tc-stab (8),
+.BR tc-tbf (8),
 .br
 .RB "User documentation at " http://lartc.org/ ", but please direct bugreports and patches to: " <netdev@vger.kernel.org>
 
-- 
1.7.0.4
