From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 14/15] dlm: make config_item_type const
Date: Mon, 16 Oct 2017 17:18:53 +0200
Message-ID: <1508167134-6243-15-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
	alexander.shishkin@linux.intel.com, jic23@kernel.org, knaack.h@gmx.de,
	lars@metafoo.de, pmeerw@pmeerw.net, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, hch@lst.de,
	sagi@grimberg.me, kishon@ti.com, bhelgaas@google.com,
	nab@linux-iscsi.org, balbi@kernel.org, gregkh@linuxfoundation.org,
	laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
	ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
	target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
	cluster-devel@redhat.com, ocfs2-devel@oss.oracle.com,
	linux-fsdevel@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Make config_item_type structures const as they are either passed to a
function having the argument as const or stored in the const "ci_type"
field of a config_item structure.

Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 fs/dlm/config.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/dlm/config.c b/fs/dlm/config.c
index 7211e82..1270551 100644
--- a/fs/dlm/config.c
+++ b/fs/dlm/config.c
@@ -282,44 +282,44 @@ struct dlm_node {
 	.release = release_node,
 };
 
-static struct config_item_type clusters_type = {
+static const struct config_item_type clusters_type = {
 	.ct_group_ops = &clusters_ops,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type cluster_type = {
+static const struct config_item_type cluster_type = {
 	.ct_item_ops = &cluster_ops,
 	.ct_attrs = cluster_attrs,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type spaces_type = {
+static const struct config_item_type spaces_type = {
 	.ct_group_ops = &spaces_ops,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type space_type = {
+static const struct config_item_type space_type = {
 	.ct_item_ops = &space_ops,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type comms_type = {
+static const struct config_item_type comms_type = {
 	.ct_group_ops = &comms_ops,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type comm_type = {
+static const struct config_item_type comm_type = {
 	.ct_item_ops = &comm_ops,
 	.ct_attrs = comm_attrs,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type nodes_type = {
+static const struct config_item_type nodes_type = {
 	.ct_group_ops = &nodes_ops,
 	.ct_owner = THIS_MODULE,
 };
 
-static struct config_item_type node_type = {
+static const struct config_item_type node_type = {
 	.ct_item_ops = &node_ops,
 	.ct_attrs = node_attrs,
 	.ct_owner = THIS_MODULE,
-- 
1.9.1
