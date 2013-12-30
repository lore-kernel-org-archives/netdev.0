From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Document the "ip link add index IDX" possibility
Date: Mon, 30 Dec 2013 13:55:17 +0400
Message-ID: <52C14305.8070401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55774 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139Ab3L3Jza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 04:55:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@paralles.com>

---

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 3986a5a..94d07fc 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -39,6 +39,8 @@ ip-link \- network device configuration
 .br
 .RB "[ " mtu
 .IR MTU " ]"
+.RB "[ " index
+.IR IDX " ]"
 .br
 .RB "[ " numtxqueues
 .IR QUEUE_COUNT " ]"
@@ -218,6 +220,10 @@ specifies the number of transmit queues for new device.
 specifies the number of receive queues for new device.
 
 .TP
+.BI index " IDX "
+specifies the desired index of the new virtual device. The link creation fails, if the index is busy.
+
+.TP
 VXLAN Type Support
 For a link of type 
 .I VXLAN
