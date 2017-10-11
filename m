From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH v2 net 0/2] net/smc: ib_query_gid() patches
Date: Wed, 11 Oct 2017 13:47:21 +0200
Message-ID: <20171011114723.30733-1-ubraun@linux.vnet.ibm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

triggered by Parav Pandit here are 2 cleanup patches for usage of
ib_query_gid() in the smc-code.

Thanks, Ursula

v2 changes advised by Parav Pandit:
   extra check is_vlan_dev() in patch 2/2
   "RoCE" spelling
   added "Reported-by"
   added "Reviewed-by"
   added "Fixes"

Ursula Braun (2):
  net/smc: replace function pointer get_netdev()
  net/smc: dev_put for netdev after usage of ib_query_gid()

 net/smc/smc_core.c | 12 ++++++++----
 net/smc/smc_ib.c   | 26 +++++++++-----------------
 2 files changed, 17 insertions(+), 21 deletions(-)

-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
