From: Thomas Graf <tgraf@suug.ch>
Subject: [NET] 82596: Add missing parenthesis
Date: Mon, 27 Aug 2007 14:48:15 +0200
Message-ID: <20070827124815.GD894@postel.suug.ch>
References: <Pine.LNX.4.64.0708271522400.16245@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46406 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbXH0Mry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 08:47:54 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708271522400.16245@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/drivers/net/82596.c
===================================================================
--- net-2.6.24.orig/drivers/net/82596.c	2007-08-27 14:43:16.000000000 +0200
+++ net-2.6.24/drivers/net/82596.c	2007-08-27 14:43:51.000000000 +0200
@@ -1562,7 +1562,7 @@ static void set_multicast_list(struct ne
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address " MAC_FMT "\n",
-						dev->name, MAC_ARG(cp));
+						dev->name, MAC_ARG(cp)));
 		}
 		i596_add_cmd(dev, &cmd->cmd);
 	}
