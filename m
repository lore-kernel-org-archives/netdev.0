From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 15/15] net: kill dev->master
Date: Tue, 14 Aug 2012 17:05:48 +0200
Message-ID: <1344956748-2099-16-git-send-email-jiri@resnulli.us>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nobody uses this now. Remove it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c689593..8459f72 100644
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
