From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/3] arp_notify: document that a gratuitous ARP request is sent when this option is enabled
Date: Wed, 26 May 2010 11:09:41 +0100
Message-ID: <1274868583-26291-1-git-send-email-ian.campbell@citrix.com>
References: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45651 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933942Ab0EZKIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 06:08:55 -0400
In-Reply-To: <1274868492.24218.7350.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This option causes a gratuitous ARP request, not a reply as the documentation
currently suggests.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 Documentation/networking/ip-sysctl.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 8b72c88..bd13884 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -872,7 +872,7 @@ arp_ignore - INTEGER
 arp_notify - BOOLEAN
 	Define mode for notification of address and device changes.
 	0 - (default): do nothing
-	1 - Generate gratuitous arp replies when device is brought up
+	1 - Generate gratuitous arp requests when device is brought up
 	    or hardware address changes.
 
 arp_accept - BOOLEAN
-- 
1.5.6.5

