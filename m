From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [IPROUTE2 1/2] Update tc-netem manpage to add ecn capability
Date: Wed, 16 May 2012 16:51:57 -0700
Message-ID: <1337212318-2100-2-git-send-email-subramanian.vijay@gmail.com>
References: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40502 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760721Ab2EPXud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 19:50:33 -0400
Received: by dady13 with SMTP id y13so1644444dad.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 16:50:32 -0700 (PDT)
In-Reply-To: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the netem manpage to describe how to use
netem to mark packets with ecn instead of dropping them.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/tc-netem.8 |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
index 39f8454..b0b7864 100644
--- a/man/man8/tc-netem.8
+++ b/man/man8/tc-netem.8
@@ -30,8 +30,8 @@ NetEm \- Network Emulator
 .IR p13 " [ " p31 " [ " p32 " [ " p23 " [ " p14 "]]]] |"
 .br
 .RB "               " gemodel
-.IR p " [ " r " [ " 1-h " [ " 1-k " ]]]"
-.BR " }"
+.IR p " [ " r " [ " 1-h " [ " 1-k " ]]] } "
+.RB  " [ " ecn " ] "
 
 .IR CORRUPT " := "
 .B corrupt
@@ -102,6 +102,10 @@ model. As known, p and r are the transition probabilities between the bad and
 the good states, 1-h is the loss probability in the bad state and 1-k is the
 loss probability in the good state.
 
+.SS ecn
+can be used optionally to mark packets instead of dropping them. A loss model
+has to be used for this to be enabled.
+
 .SS corrupt
 allows the emulation of random noise introducing an error in a random position
 for a chosen percent of packets. It is also possible to add a correlation
-- 
1.7.0.4
