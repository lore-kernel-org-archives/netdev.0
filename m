From: Jean Delvare <khali@linux-fr.org>
Subject: [PATCH] Update the /proc/net/tcp documentation
Date: Mon, 15 Oct 2007 19:15:07 +0200
Message-ID: <20071015191507.1750bc97@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-dmz-231-monday.dmz.nerim.net ([195.5.254.231]:57856 "EHLO
	kellthuzad.dmz.nerim.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752949AbXJORRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 13:17:12 -0400
Received: from kraid.nerim.net (smtp-101-monday.nerim.net [62.4.16.101])
	by kellthuzad.dmz.nerim.net (Postfix) with ESMTP id 1228323E31
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 19:17:03 +0200 (CEST)
Received: from hyperion.delvare (jdelvare.pck.nerim.net [62.212.121.182])
	by kraid.nerim.net (Postfix) with ESMTP id 589B9CF0E7
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 19:15:07 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Say that this interface is deprecated.
* Update function name references to match the current code.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
---
Second version, updated based on Rick Jones' comments.

 Documentation/networking/proc_net_tcp.txt |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-2.6.23-rc0.orig/Documentation/networking/proc_net_tcp.txt	2007-10-15 10:12:39.000000000 +0200
+++ linux-2.6.23-rc0/Documentation/networking/proc_net_tcp.txt	2007-10-15 19:11:57.000000000 +0200
@@ -1,8 +1,9 @@
 This document describes the interfaces /proc/net/tcp and /proc/net/tcp6.
+Note that these interfaces are deprecated in favor of tcp_diag.
 
 These /proc interfaces provide information about currently active TCP 
-connections, and are implemented by tcp_get_info() in net/ipv4/tcp_ipv4.c and
-tcp6_get_info() in net/ipv6/tcp_ipv6.c, respectively.
+connections, and are implemented by tcp4_seq_show() in net/ipv4/tcp_ipv4.c
+and tcp6_seq_show() in net/ipv6/tcp_ipv6.c, respectively.
 
 It will first list all listening TCP sockets, and next list all established
 TCP connections. A typical entry of /proc/net/tcp would look like this (split 


-- 
Jean Delvare
