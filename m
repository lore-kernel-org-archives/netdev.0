From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH V2 net 0/1] net/smc and the RDMA core
Date: Fri, 12 May 2017 19:09:51 +0200
Message-ID: <20170512170952.39863-1-ubraun@linux.vnet.ibm.com>
Cc: hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>

Hi Dave,

yesterday I included a patch proposal into a response to Christoph Hellwig,
which is now already seen here:
   http://patchwork.ozlabs.org/patch/761250/

Christoph suggested an additional improvement not to use __internal_mr.
Thus I come up with this improved version V2.

Kind regards, Ursula

Ursula Braun (1):
  smc: switch to usage of IB_PD_UNSAFE_GLOBAL_RKEY

 net/smc/smc_clc.c  |  4 ++--
 net/smc/smc_core.c | 16 +++-------------
 net/smc/smc_core.h |  2 +-
 net/smc/smc_ib.c   | 21 ++-------------------
 net/smc/smc_ib.h   |  2 --
 5 files changed, 8 insertions(+), 37 deletions(-)

-- 
2.10.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
