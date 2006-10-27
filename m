From: "Steve Wise" <swise@opengridcomputing.com>
Subject: [PATCH 2.6.19-rc3 2/2] amso1100 - Fix
 incorrect pr_debug().
Date: Fri, 27 Oct 2006 15:58:39 -0500
Message-ID: <20061027205839.8511.84399.stgit@dell3.ogc.int>
References: <20061027205819.8511.85102.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <20061027205819.8511.85102.stgit@dell3.ogc.int>
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


pr_debug() was printing the wrong stuff.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/amso1100/c2_rnic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_rnic.c b/drivers/infiniband/hw/amso1100/c2_rnic.c
index 6d82464..e1d31fb 100644
--- a/drivers/infiniband/hw/amso1100/c2_rnic.c
+++ b/drivers/infiniband/hw/amso1100/c2_rnic.c
@@ -545,8 +545,8 @@ int c2_rnic_init(struct c2_dev *c2dev)
 		goto bail2;
 	}
 	pci_unmap_addr_set(&c2dev->aeq, mapping, c2dev->aeq.host_dma);
-	pr_debug("%s aeq va %p dma %llx\n", __FUNCTION__, q1_pages,
-		 (unsigned long long) c2dev->rep_vq.host_dma);
+	pr_debug("%s aeq va %p dma %llx\n", __FUNCTION__, q2_pages,
+		 (unsigned long long) c2dev->aeq.host_dma);
 	c2_mq_rep_init(&c2dev->aeq,
 		       2,
 		       qsize,
