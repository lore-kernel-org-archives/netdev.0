From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/15] net: kill dev->master
Date: Sun, 30 Dec 2012 12:58:22 +0100
Message-ID: <1356868702-8144-16-git-send-email-jiri@resnulli.us>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:55619 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab2L3MB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 07:01:27 -0500
Received: by mail-ee0-f51.google.com with SMTP id d4so5701783eek.24
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 04:01:26 -0800 (PST)
In-Reply-To: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nobody uses this now. Remove it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c3723ef..009bad3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1167,10 +1167,6 @@ struct net_device {
 						 * avoid dirtying this cache line.
 						 */
 
-	struct net_device	*master; /* Pointer to master device of a group,
-					  * which this device is member of.
-					  */
-
 	struct list_head	upper_dev_list; /* List of upper devices */
 
 	/* Interface address info used in eth_type_trans() */
-- 
1.8.0
