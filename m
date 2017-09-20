From: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH net-next 00/10] net/smc: updates 2017-09-20
Date: Wed, 20 Sep 2017 13:58:03 +0200
Message-ID: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
        schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here is a collection of small smc-patches built for net-next improving
the smc code in different areas.

Thanks,
Ursula

Hans Wippel (2):
  net/smc: add missing dev_put
  net/smc: add receive timeout check

Ursula Braun (8):
  net/smc: take RCU read lock for routing cache lookup
  net/smc: adjust net_device refcount
  net/smc: adapt send request completion notification
  net/smc: longer delay for client link group removal
  net/smc: terminate link group if out-of-sync is received
  net/smc: introduce a delay
  net/smc: parameter cleanup in smc_cdc_get_free_slot()
  net/smc: no close wait in case of process shut down

 net/smc/af_smc.c    | 16 +++++++++-------
 net/smc/smc.h       |  2 +-
 net/smc/smc_cdc.c   |  7 ++++---
 net/smc/smc_cdc.h   |  3 ++-
 net/smc/smc_clc.c   | 10 +++++-----
 net/smc/smc_clc.h   |  3 +--
 net/smc/smc_close.c | 27 +++++++++++++++------------
 net/smc/smc_core.c  | 16 ++++++++++++----
 net/smc/smc_ib.c    |  1 +
 net/smc/smc_pnet.c  |  4 +++-
 net/smc/smc_rx.c    |  2 ++
 net/smc/smc_tx.c    | 18 ++++++++++--------
 net/smc/smc_wr.c    |  2 +-
 13 files changed, 66 insertions(+), 45 deletions(-)

-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
