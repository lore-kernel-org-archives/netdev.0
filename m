From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] man: describe --bpf option of ss
Date: Fri, 24 May 2013 14:25:41 +0200
Message-ID: <1369398341-20145-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38205 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab3EXM0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 08:26:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This option has been recently added to ss utility.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/ss.8 | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index f03c6d8..7e8d8e8 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -57,6 +57,9 @@ Print summary statistics. This option does not parse socket lists obtaining
 summary from various sources. It is useful when amount of sockets is so huge
 that parsing /proc/net/tcp is painful.
 .TP
+.B \-b, \-\-bpf
+Show socket BPF filters (only administrators are allowed to get these information).
+.TP
 .B \-4, \-\-ipv4
 Display only IP version 4 sockets (alias for -f inet).
 .TP
-- 
1.8.2.1
