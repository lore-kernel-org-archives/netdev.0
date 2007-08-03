From: Chuck Ebbert <cebbert@redhat.com>
Subject: [patch 2.6.23-rc1] add xt_statistic.h to the header list for usermode
 programs
Date: Fri, 03 Aug 2007 13:28:09 -0400
Message-ID: <46B365A9.8080507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58303 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759399AbXHCR2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 13:28:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add xt_statistic.h to the list of headers to install.

Apparently needed to build newer versions of iptables.

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>
---
 include/linux/netfilter/Kbuild |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.22.noarch.orig/include/linux/netfilter/Kbuild
+++ linux-2.6.22.noarch/include/linux/netfilter/Kbuild
@@ -28,6 +28,7 @@ header-y += xt_policy.h
 header-y += xt_realm.h
 header-y += xt_sctp.h
 header-y += xt_state.h
+header-y += xt_statistic.h
 header-y += xt_string.h
 header-y += xt_tcpmss.h
 header-y += xt_tcpudp.h
