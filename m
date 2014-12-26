From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Small example of 'ip link show master'
Date: Fri, 26 Dec 2014 04:46:20 +0200
Message-ID: <1419561980-10914-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35635 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbaLZC4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2014 21:56:30 -0500
Received: by mail-lb0-f177.google.com with SMTP id b6so8133089lbj.36
        for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 18:56:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 5134e28..1209b55 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -739,6 +739,11 @@ ip link show type vlan
 Shows the vlan devices.
 .RE
 .PP
+ip link show master br0
+.RS 4
+Shows devices enslaved by br0
+.RE
+.PP
 ip link set dev ppp0 mtu 1400
 .RS 4
 Change the MTU the ppp0 device.
-- 
2.1.3
