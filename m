From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/16] net: kill dev->master
Date: Mon, 13 Aug 2012 17:27:15 +0200
Message-ID: <1344871635-1052-17-git-send-email-jiri@resnulli.us>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48903 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203Ab2HMP2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 11:28:04 -0400
Received: by eeil10 with SMTP id l10so1192796eei.19
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2012 08:28:03 -0700 (PDT)
In-Reply-To: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nobody uses this now. Remove it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 757f627..28c5ef0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1168,10 +1168,6 @@ struct net_device {
 						 * avoid dirtying this cache line.
 						 */
 
-	struct net_device	*master; /* Pointer to master device of a group,
-					  * which this device is member of.
-					  */
-
 	struct list_head	upper_dev_list; /* List of upper devices */
 
 	/* Interface address info used in eth_type_trans() */
-- 
1.7.10.4
