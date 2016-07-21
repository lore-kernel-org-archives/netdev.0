From: Varun Prakash <varun@chelsio.com>
Subject: [net-next v3 6/6] cxgb3i,cxgb4i: fix symbol not declared sparse warning
Date: Thu, 21 Jul 2016 22:57:19 +0530
Message-ID: <957b51f9fdd742e50ffcf954bf44422b6edab7dc.1469121308.git.varun@chelsio.com>
References: <cover.1469121308.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	gerlitz.or@gmail.com, swise@opengridcomputing.com,
	james.bottomley@hansenpartnership.com, indranil@chelsio.com,
	hariprasad@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1469121308.git.varun@chelsio.com>
In-Reply-To: <cover.1469121308.git.varun@chelsio.com>
References: <cover.1469121308.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix following sparse warnings
warning: symbol 'cxgb3i_ofld_init' was not declared. Should it be static?
warning: symbol 'cxgb4i_cplhandlers' was not declared. Should it be static?
warning: symbol 'cxgb4i_ofld_init' was not declared. Should it be static?

Signed-off-by: Varun Prakash <varun@chelsio.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c | 2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index 61f16a2..33e8346 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -1028,7 +1028,7 @@ cxgb3_cpl_handler_func cxgb3i_cpl_handlers[NUM_CPL_CMDS] = {
  * cxgb3i_ofld_init - allocate and initialize resources for each adapter found
  * @cdev:	cxgbi adapter
  */
-int cxgb3i_ofld_init(struct cxgbi_device *cdev)
+static int cxgb3i_ofld_init(struct cxgbi_device *cdev)
 {
 	struct t3cdev *t3dev = (struct t3cdev *)cdev->lldev;
 	struct adap_ports port;
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 521f9e4..e4ba2d2 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1503,7 +1503,7 @@ rel_resource_without_clip:
 	return -EINVAL;
 }
 
-cxgb4i_cplhandler_func cxgb4i_cplhandlers[NUM_CPL_CMDS] = {
+static cxgb4i_cplhandler_func cxgb4i_cplhandlers[NUM_CPL_CMDS] = {
 	[CPL_ACT_ESTABLISH] = do_act_establish,
 	[CPL_ACT_OPEN_RPL] = do_act_open_rpl,
 	[CPL_PEER_CLOSE] = do_peer_close,
@@ -1519,7 +1519,7 @@ cxgb4i_cplhandler_func cxgb4i_cplhandlers[NUM_CPL_CMDS] = {
 	[CPL_RX_DATA] = do_rx_data,
 };
 
-int cxgb4i_ofld_init(struct cxgbi_device *cdev)
+static int cxgb4i_ofld_init(struct cxgbi_device *cdev)
 {
 	int rc;
 
-- 
2.0.2
