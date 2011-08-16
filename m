From: Bernd Schubert <bernd.schubert-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/2] 3.1-git ipoib: fix NULL pointer dereference
Date: Tue, 16 Aug 2011 12:56:48 +0200
Message-ID: <20110816105648.1805137.35191.stgit@fsdevel3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following series  
- fixes a NULL pointer dereferences in ipoib_start_xmit()
- renames variable 'n' to 'dst_neigh' to make the code better readable

Question: I am unsure about the usage of likely() here, as I run into the else branch,
maybe it is not that unlikely and likely() should be removed?

---

Bernd Schubert (2):
      Fix possible Null pointer dereference in ipoib_start_xmit()
      Rename 'n' into a longer variable name.


 drivers/infiniband/ulp/ipoib/ipoib_main.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

--
Bernd Schubert
Fraunhofer ITWM / FhGFS

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
