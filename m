From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 09/15] ACPI: configfs: make
	config_item_type const
Date: Mon, 16 Oct 2017 17:18:48 +0200
Message-ID: <1508167134-6243-10-git-send-email-bhumirks@gmail.com>
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

 drivers/acpi/acpi_configfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/acpi_configfs.c b/drivers/acpi/acpi_configfs.c
index 853bc7f..b588503 100644
--- a/drivers/acpi/acpi_configfs.c
+++ b/drivers/acpi/acpi_configfs.c
@@ -204,7 +204,7 @@ struct configfs_attribute *acpi_table_attrs[] = {
 	NULL,
 };
 
-static struct config_item_type acpi_table_type = {
+static const struct config_item_type acpi_table_type = {
 	.ct_owner = THIS_MODULE,
 	.ct_bin_attrs = acpi_table_bin_attrs,
 	.ct_attrs = acpi_table_attrs,
@@ -237,12 +237,12 @@ struct configfs_group_operations acpi_table_group_ops = {
 	.drop_item = acpi_table_drop_item,
 };
 
-static struct config_item_type acpi_tables_type = {
+static const struct config_item_type acpi_tables_type = {
 	.ct_owner = THIS_MODULE,
 	.ct_group_ops = &acpi_table_group_ops,
 };
 
-static struct config_item_type acpi_root_group_type = {
+static const struct config_item_type acpi_root_group_type = {
 	.ct_owner = THIS_MODULE,
 };
 
-- 
1.9.1
