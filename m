From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 3/4] ip-link.8: document "external" flag for vxlan
Date: Thu,  7 Apr 2016 14:36:28 +0200
Message-ID: <afd89e68236fec8fc61bd28780179d0f35be09a6.1460032274.git.jbenc@redhat.com>
References: <cover.1460032274.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755557AbcDGMhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 08:37:23 -0400
In-Reply-To: <cover.1460032274.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 man/man8/ip-link.8.in | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 805511423ef2..f677f8c55365 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -422,6 +422,8 @@ the following additional arguments are supported:
 ] [
 .BI maxaddress " NUMBER "
 ] [
+.RI "[no]external "
+] [
 .B gbp
 ]
 
@@ -516,6 +518,12 @@ are entered into the VXLAN device forwarding database.
 - specifies the maximum number of FDB entries.
 
 .sp
+.I [no]external
+- specifies whether an external control plane
+.RB "(e.g. " "ip route encap" )
+or the internal FDB should be used.
+
+.sp
 .B gbp
 - enables the Group Policy extension (VXLAN-GBP).
 
-- 
1.8.3.1
