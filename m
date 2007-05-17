From: Dave Jones <davej@redhat.com>
Subject: Correct rp_filter help text.
Date: Thu, 17 May 2007 17:58:19 -0400
Message-ID: <20070517215819.GA8580@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754770AbXEQV6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 17:58:22 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l4HLwLa2028369
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:58:21 -0400
Received: from gelk.kernelslacker.org (vpn-248-1.boston.redhat.com [10.13.248.1])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l4HLwK7C014730
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:58:20 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.13.8/8.13.8) with ESMTP id l4HLwKci011441
	for <netdev@vger.kernel.org>; Thu, 17 May 2007 17:58:20 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.13.8/8.13.8/Submit) id l4HLwJ39011440
	for netdev@vger.kernel.org; Thu, 17 May 2007 17:58:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As mentioned in http://bugzilla.kernel.org/show_bug.cgi?id=5015
The helptext implies that this is on by default.
This may be true on some distros (Fedora/RHEL have it enabled
in /etc/sysctl.conf), but the kernel defaults to it off.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index c68196c..420d7a4 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -43,11 +43,11 @@ config IP_ADVANCED_ROUTER
 	  asymmetric routing (packets from you to a host take a different path
 	  than packets from that host to you) or if you operate a non-routing
 	  host which has several IP addresses on different interfaces. To turn
-	  rp_filter off use:
+	  rp_filter on use:
 
-	  echo 0 > /proc/sys/net/ipv4/conf/<device>/rp_filter
+	  echo 1 > /proc/sys/net/ipv4/conf/<device>/rp_filter
 	  or
-	  echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
+	  echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
 
 	  If unsure, say N here.
 

-- 
http://www.codemonkey.org.uk
