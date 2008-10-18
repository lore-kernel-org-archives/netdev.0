From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] bonding: remove change name TODO
Date: Fri, 17 Oct 2008 21:32:58 -0700
Message-ID: <20081018043323.806248689@vyatta.com>
References: <20081018043252.968940967@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vousburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52226 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189AbYJREiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:38:00 -0400
Content-Disposition: inline; filename=bond-primary-change.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the name of the bonding primary is already handled. The only
place the name is stored is in bond->params.primary, and that is only used
during startup.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2008-10-17 16:50:42.000000000 -0700
+++ b/drivers/net/bonding/bond_main.c	2008-10-17 16:50:45.000000000 -0700
@@ -3580,11 +3580,6 @@ static int bond_slave_netdev_event(unsig
 			return NOTIFY_BAD;
 		break;
 
-	case NETDEV_CHANGENAME:
-		/*
-		 * TODO: handle changing the primary's name
-		 */
-		break;
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
 		break;

-- 

