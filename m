From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/5] man: ip-link: Beef up VXLAN csum options a bit
Date: Fri,  4 Mar 2016 12:52:38 +0100
Message-ID: <1457092361-17603-3-git-send-email-phil@nwl.cc>
References: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51758 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbcCDLxA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 06:53:00 -0500
In-Reply-To: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index c6a9c862dfda2..2cd93b0ff718e 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -491,15 +491,15 @@ are entered into the VXLAN device forwarding database.
 
 .sp
 .I [no]udpcsum
-- specifies if UDP checksum is filled in
+- specifies if UDP checksum is calculated for transmitted packets over IPv4.
 
 .sp
 .I [no]udp6zerocsumtx
-- specifies if UDP checksum is filled in
+- skip UDP checksum calculation for transmitted packets over IPv6.
 
 .sp
 .I [no]udp6zerocsumrx
-- specifies if UDP checksum is received
+- allow incoming UDP packets over IPv6 with zero checksum field.
 
 .sp
 .BI ageing " SECONDS"
-- 
2.7.2
