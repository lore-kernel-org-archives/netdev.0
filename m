From: Hal Rosenstock <halr@voltaire.com>
Subject: [PATCH] netdevice.h: Add RDMA private pointer to
	the net_device structure
Date: 03 Oct 2005 14:48:44 -0400
Message-ID: <1128365323.4397.38.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

netdevice.h: Add RDMA private pointer to the net_device structure

Signed-off-by: Hal Rosenstock <halr@voltaire.com>

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -366,6 +366,7 @@ struct net_device
        void                    *ip6_ptr;       /* IPv6 specific data */
        void                    *ec_ptr;        /* Econet specific data */
        void                    *ax25_ptr;      /* AX.25 specific data */
+       void                    *rdma_ptr;      /* RDMA specific data */
 
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
