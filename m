From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] man: update doc after support of ESN and anti-replay window
Date: Thu, 30 Oct 2014 09:18:40 +0100
Message-ID: <1414657120-5572-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53376 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbaJ3ISr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 04:18:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/ip-xfrm.8 | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 2d31b4d9c5a2..c9d2a2e17c35 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -43,6 +43,10 @@ ip-xfrm \- transform configuration
 .IR SEQ " ]"
 .RB "[ " replay-oseq
 .IR SEQ " ]"
+.RB "[ " replay-seq-hi
+.IR SEQ " ]"
+.RB "[ " replay-oseq-hi
+.IR SEQ " ]"
 .RB "[ " flag
 .IR FLAG-LIST " ]"
 .RB "[ " sel
@@ -138,7 +142,8 @@ ip-xfrm \- transform configuration
 
 .ti -8
 .IR FLAG " :="
-.BR noecn " | " decap-dscp " | " nopmtudisc " | " wildrecv " | " icmp " | " af-unspec " | " align4
+.BR noecn " | " decap-dscp " | " nopmtudisc " | " wildrecv " | " icmp " | "
+.BR af-unspec " | " align4 " | " esn
 
 .ti -8
 .IR SELECTOR " :="
@@ -470,7 +475,7 @@ and inbound trigger
 .I FLAG-LIST
 contains one or more of the following optional flags:
 .BR noecn ", " decap-dscp ", " nopmtudisc ", " wildrecv ", " icmp ", "
-.BR af-unspec ", or " align4 "."
+.BR af-unspec ", " align4 ", or " esn "."
 
 .TP
 .IR SELECTOR
-- 
2.1.0
