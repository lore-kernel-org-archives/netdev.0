From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/2] Fix OPA_VNIC issues with debug kernel
Date: Wed, 14 Jun 2017 12:34:26 -0700
Message-ID: <1497468868-19122-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Doug,
Here are couple OPA_VNIC bug fixes.
As OPA_VNIC is alredy included for 4.12, it would be great
to get them into the RC release.

Thanks,
Niranjana

Vishwanathapura, Niranjana (2):
  IB/opa_vnic: Use GFP_ATOMIC while sending trap
  IB/opa_vnic: Use spinlock instead of mutex for stats_lock

 drivers/infiniband/ulp/opa_vnic/opa_vnic_ethtool.c    | 4 ++--
 drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h   | 2 +-
 drivers/infiniband/ulp/opa_vnic/opa_vnic_netdev.c     | 8 +++-----
 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c       | 2 +-
 drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c | 8 ++++----
 5 files changed, 11 insertions(+), 13 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
