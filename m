From: Jean Delvare <khali@linux-fr.org>
Subject: [PATCH] Update function names in /proc/net/tcp documentation
Date: Fri, 12 Oct 2007 22:54:26 +0200
Message-ID: <20071012225426.2f866ae6@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-dmz-235-friday.dmz.nerim.net ([195.5.254.235]:62457 "EHLO
	kellthuzad.dmz.nerim.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757178AbXJLVjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 17:39:08 -0400
Received: from mallaury.nerim.net (smtp-105-friday.noc.nerim.net [62.4.17.105])
	by kellthuzad.dmz.nerim.net (Postfix) with ESMTP id CA1C83A9A4
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 22:56:19 +0200 (CEST)
Received: from hyperion.delvare (jdelvare.pck.nerim.net [62.212.121.182])
	by mallaury.nerim.net (Postfix) with ESMTP id B64564F3C1
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 22:54:13 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update function name references to match the current code.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
---
 Documentation/networking/proc_net_tcp.txt |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.23.orig/Documentation/networking/proc_net_tcp.txt	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.23/Documentation/networking/proc_net_tcp.txt	2007-10-12 22:50:15.000000000 +0200
@@ -1,8 +1,8 @@
 This document describes the interfaces /proc/net/tcp and /proc/net/tcp6.
 
 These /proc interfaces provide information about currently active TCP 
-connections, and are implemented by tcp_get_info() in net/ipv4/tcp_ipv4.c and
-tcp6_get_info() in net/ipv6/tcp_ipv6.c, respectively.
+connections, and are implemented by tcp4_seq_show() in net/ipv4/tcp_ipv4.c
+and tcp6_seq_show() in net/ipv6/tcp_ipv6.c, respectively.
 
 It will first list all listening TCP sockets, and next list all established
 TCP connections. A typical entry of /proc/net/tcp would look like this (split 


-- 
Jean Delvare
