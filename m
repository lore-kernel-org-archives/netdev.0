From: Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/2] Re-submit RDS patches
Date: Fri, 21 Dec 2012 13:01:43 -0500
Message-ID: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These fixes were originally submitted in
https://oss.oracle.com/pipermail/rds-devel/2012-April/thread.html.

The first patch fixes a DOA issue with RDS on qib and should
be a stable patch as well.

The second suppresses a warning message that is misleading when 
a version has been correctly determined.

These two patches were originally acked by the upstream maintainer
and never merged.

---

Mike Marciniszyn (2):
      IB/rds: Correct ib_api use with gs_dma_address/sg_dma_len
      IB/rds: suppress incompatible protocol when version is known


 net/rds/ib_cm.c   |   11 +++++------
 net/rds/ib_recv.c |    9 ++++++---
 2 files changed, 11 insertions(+), 9 deletions(-)

-- 
Thanks!
Mike Marciniszyn
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
