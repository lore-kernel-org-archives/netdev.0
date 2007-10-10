From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] do not give access to 1-1024 ports for autobinding
Date: Wed, 10 Oct 2007 18:34:49 +0400
Message-ID: <20071010143449.GA10796@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:62685 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753950AbXJJOdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 10:33:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch prevents possibility to give 1-1024 port range for autobinding.
{1, 1} may only takes some sense for deep embedded people.

Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./net/ipv4/sysctl_net_ipv4.c.port2	2007-10-10 17:46:48.000000000 +0400
+++ ./net/ipv4/sysctl_net_ipv4.c	2007-10-10 18:08:00.000000000 +0400
@@ -25,7 +25,7 @@ extern int sysctl_ip_nonlocal_bind;
 #ifdef CONFIG_SYSCTL
 static int zero;
 static int tcp_retr1_max = 255;
-static int ip_local_port_range_min[] = { 1, 1 };
+static int ip_local_port_range_min[] = { 1024, 1024 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 #endif
 
