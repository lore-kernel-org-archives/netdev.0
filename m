From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ppp: make  ppp_get_stats64 static
Date: Mon, 29 Oct 2012 11:34:02 -0700
Message-ID: <20121029113402.10736805@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46210 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756517Ab2J2Sew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 14:34:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was picked up by sparse.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ppp/ppp_generic.c	2012-10-25 09:11:13.963289236 -0700
+++ b/drivers/net/ppp/ppp_generic.c	2012-10-29 11:26:06.167077708 -0700
@@ -1034,7 +1034,7 @@ ppp_net_ioctl(struct net_device *dev, st
 	return err;
 }
 
-struct rtnl_link_stats64*
+static struct rtnl_link_stats64*
 ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 {
 	struct ppp *ppp = netdev_priv(dev);
