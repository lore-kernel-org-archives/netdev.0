From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 12/15] RDMA/cma: make config_item_type
	const
Date: Mon, 16 Oct 2017 17:18:51 +0200
Message-ID: <1508167134-6243-13-git-send-email-bhumirks@gmail.com>
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

Make these structures const as they are either passed to the functions
having the argument as const or stored as a reference in the "ci_type"
const field of a config_item structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/infiniband/core/cma_configfs.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/cma_configfs.c b/drivers/infiniband/core/cma_configfs.c
index 54076a3..31dfee0 100644
--- a/drivers/infiniband/core/cma_configfs.c
+++ b/drivers/infiniband/core/cma_configfs.c
@@ -186,7 +186,7 @@ static ssize_t default_roce_tos_store(struct config_item *item,
 	NULL,
 };
 
-static struct config_item_type cma_port_group_type = {
+static const struct config_item_type cma_port_group_type = {
 	.ct_attrs	= cma_configfs_attributes,
 	.ct_owner	= THIS_MODULE
 };
@@ -263,7 +263,7 @@ static void release_cma_ports_group(struct config_item  *item)
 	.release = release_cma_ports_group
 };
 
-static struct config_item_type cma_ports_group_type = {
+static const struct config_item_type cma_ports_group_type = {
 	.ct_item_ops	= &cma_ports_item_ops,
 	.ct_owner	= THIS_MODULE
 };
@@ -272,7 +272,7 @@ static void release_cma_ports_group(struct config_item  *item)
 	.release = release_cma_dev
 };
 
-static struct config_item_type cma_device_group_type = {
+static const struct config_item_type cma_device_group_type = {
 	.ct_item_ops	= &cma_device_item_ops,
 	.ct_owner	= THIS_MODULE
 };
@@ -323,7 +323,7 @@ static struct config_group *make_cma_dev(struct config_group *group,
 	.make_group	= make_cma_dev,
 };
 
-static struct config_item_type cma_subsys_type = {
+static const struct config_item_type cma_subsys_type = {
 	.ct_group_ops	= &cma_subsys_group_ops,
 	.ct_owner	= THIS_MODULE,
 };
-- 
1.9.1
