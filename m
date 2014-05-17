From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bridge: fix spelling of promiscuous
Date: Fri, 16 May 2014 20:46:17 -0700
Message-ID: <20140516204617.7bddc581@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60743 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035AbaEQDqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 23:46:20 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so3335985pab.19
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 20:46:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/bridge/br_if.c	2014-05-16 20:27:32.487420011 -0700
+++ b/net/bridge/br_if.c	2014-05-16 20:36:45.860301171 -0700
@@ -178,7 +178,7 @@ static void nbp_update_port_count(struct
 
 static void nbp_delete_promisc(struct net_bridge_port *p)
 {
-	/* If port is currently promiscous, unset promiscuity.
+	/* If port is currently promiscuous, unset promiscuity.
 	 * Otherwise, it is a static port so remove all addresses
 	 * from it.
 	 */
