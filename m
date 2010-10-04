From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Software iWARP (SIW) patches
Date: Mon, 4 Oct 2010 16:27:51 +0200
Message-ID: <OFB52DA6A6.F41C82CB-ONC12577B2.004605E9-C12577B2.004F74B9@ch.ibm.com>
References: <1285187710.1849.82.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285187710.1849.82.camel-Y1+j5t8j3WgjMeEPmliV8E/sVC8ogwMJ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

All,
many thanks for your suggestions and help in preparing a set of
patches to add an in-kernel, full-software iWARP stack. As suggested,
the patches are against the current net-next-2.6.git repository,
all version dependencies etc. are removed. To avoid redundancy,
the patches will be posted to the netdev list only. Please keep
me on cc on any replies, since I am not subscribed to netdev.

We post the patches in the hope to make a useful contribution
to the Linux networking stack, and we hope to see SoftiWARP
becoming part of a future mainline Linux. Of course we are very open
to all discussion, suggestions and comments to improve quality and
completeness of the current code. Many thanks in advance!

We will keep www.gitorious.org/softiwarp updated to make a version
of SoftiWARP kernel and user code available for immediate testing
on a running system.
The code at gitorious differs from the current patch in its extensions
to support older kernel versions. All these extensions are #ifdef'ed
and are not part of the upcoming patch series.
www.gitorious.org/softiwarp/userlib remains the current source of the
user library for SoftiWARP.

Please find below both git shortlog and diffstat for overview.


Many Thanks,
Bernard.
--

Bernard Metzler (13):
      SIW: Kconfig and Makefile
      SIW: iWARP Protocol headers
      SIW: Main header file
      SIW: Module initialization
      SIW: User interface
      SIW: Connection management
      SIW: Object management
      SIW: Queue pair
      SIW: Completion queue
      SIW: Transmit path
      SIW: Receive path
      SIW: Debugging and Tracing
      SIW: Documentation (initial)

 Documentation/networking/siw.txt      |   91 ++
 drivers/infiniband/Kconfig            |    1 +
 drivers/infiniband/Makefile           |    1 +
 drivers/infiniband/hw/siw/Kconfig     |   14 +
 drivers/infiniband/hw/siw/Makefile    |    5 +
 drivers/infiniband/hw/siw/iwarp.h     |  324 ++++++
 drivers/infiniband/hw/siw/siw.h       |  816 ++++++++++++++
 drivers/infiniband/hw/siw/siw_ae.c    |   96 ++
 drivers/infiniband/hw/siw/siw_cm.c    | 1939 +++++++++++++++++++++++++++++
++++
 drivers/infiniband/hw/siw/siw_cm.h    |  155 +++
 drivers/infiniband/hw/siw/siw_cq.c    |  243 ++++
 drivers/infiniband/hw/siw/siw_debug.c |  198 ++++
 drivers/infiniband/hw/siw/siw_debug.h |  159 +++
 drivers/infiniband/hw/siw/siw_main.c  |  440 ++++++++
 drivers/infiniband/hw/siw/siw_obj.c   |  499 +++++++++
 drivers/infiniband/hw/siw/siw_obj.h   |  109 ++
 drivers/infiniband/hw/siw/siw_qp.c    |  989 +++++++++++++++++
 drivers/infiniband/hw/siw/siw_qp_rx.c | 1493 +++++++++++++++++++++++++
 drivers/infiniband/hw/siw/siw_qp_tx.c | 1309 ++++++++++++++++++++++
 drivers/infiniband/hw/siw/siw_user.h  |   66 ++
 drivers/infiniband/hw/siw/siw_verbs.c | 1564 ++++++++++++++++++++++++++
 drivers/infiniband/hw/siw/siw_verbs.h |   96 ++
 22 files changed, 10607 insertions(+), 0 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
