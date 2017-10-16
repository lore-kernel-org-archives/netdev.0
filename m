From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 10/15] nullb: make config_item_type const
Date: Mon, 16 Oct 2017 17:18:49 +0200
Message-ID: <1508167134-6243-11-git-send-email-bhumirks@gmail.com>
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

Done using Coccienlle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/block/null_blk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/null_blk.c b/drivers/block/null_blk.c
index bf2c8ca..46b6008 100644
--- a/drivers/block/null_blk.c
+++ b/drivers/block/null_blk.c
@@ -480,7 +480,7 @@ static void nullb_device_release(struct config_item *item)
 	.release	= nullb_device_release,
 };
 
-static struct config_item_type nullb_device_type = {
+static const struct config_item_type nullb_device_type = {
 	.ct_item_ops	= &nullb_device_ops,
 	.ct_attrs	= nullb_device_attrs,
 	.ct_owner	= THIS_MODULE,
@@ -532,7 +532,7 @@ static ssize_t memb_group_features_show(struct config_item *item, char *page)
 	.drop_item	= nullb_group_drop_item,
 };
 
-static struct config_item_type nullb_group_type = {
+static const struct config_item_type nullb_group_type = {
 	.ct_group_ops	= &nullb_group_ops,
 	.ct_attrs	= nullb_group_attrs,
 	.ct_owner	= THIS_MODULE,
-- 
1.9.1
