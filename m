From: Milan Kocian <milon@wq.cz>
Subject: [PATCH 1/1] ipv6: remove redundant RTM_DELLINK message
Date: Thu, 13 Sep 2007 11:57:38 +0200
Message-ID: <20070913095738.GA4168@wq.cz>
References: <20070815143322.GA25640@wq.cz> <20070821.002058.102575162.davem@davemloft.net> <20070829215119.GB15856@wq.cz> <20070906104711.GV18480@postel.suug.ch> <20070906210550.GA13542@wq.cz> <20070907101137.GX18480@postel.suug.ch> <20070912145030.GA29748@wq.cz> <20070912145323.GE18480@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:38501 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752385AbXIMJ5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 05:57:43 -0400
Content-Disposition: inline
In-Reply-To: <20070912145323.GE18480@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove useless message. We get right message from other subsystem.
---

--- a/net/ipv6/addrconf.c	2007-09-13 11:22:31.087494976 +0200
+++ b/net/ipv6/addrconf.c	2007-09-13 11:25:56.056225711 +0200
@@ -2486,9 +2486,7 @@ static int addrconf_ifdown(struct net_de
 	else
 		ipv6_mc_down(idev);
 
-	/* Step 5: netlink notification of this interface */
 	idev->tstamp = jiffies;
-	inet6_ifinfo_notify(RTM_DELLINK, idev);
 
 	/* Shot the device (if unregistered) */
 
Signed-off-by: Milan Kocian <milon@wq.cz>

