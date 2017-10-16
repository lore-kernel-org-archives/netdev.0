From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH v2 13/15] netconsole: make config_item_type const
Date: Mon, 16 Oct 2017 17:18:52 +0200
Message-ID: <1508167134-6243-14-git-send-email-bhumirks@gmail.com>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        alexander.shishkin@linux.intel.com, jic23@kernel.org,
        knaack.h@gmx.de, lars@metafoo.de, pmeerw@pmeerw.net,
        dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, hch@lst.de, sagi@grimberg.me,
        kishon@ti.com, bhelgaas@google.com, nab@linux-iscsi.org,
        balbi@kernel.org, gregkh@linuxfoundation.org,
        laurent.pinchart@ideasonboard.com, jlbec@evilplan.org,
        ccaulfie@redhat.com, teigland@redhat.com, mfasheh@versity.com,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-usb@vger.kernel.org,
        cluster-devel@redh
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1508167134-6243-1-git-send-email-bhumirks@gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these structures const as they are either passed to the functions
having the argument as const or stored as a reference in the "ci_type"
const field of a config_item structure.

Done using Coccienlle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
* Changes in v2- Combine all the followup patches and the constification
patches into a series.

 drivers/net/netconsole.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 0e27920..be9aa36 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -616,7 +616,7 @@ static void netconsole_target_release(struct config_item *item)
 	.release		= netconsole_target_release,
 };
 
-static struct config_item_type netconsole_target_type = {
+static const struct config_item_type netconsole_target_type = {
 	.ct_attrs		= netconsole_target_attrs,
 	.ct_item_ops		= &netconsole_target_item_ops,
 	.ct_owner		= THIS_MODULE,
@@ -682,7 +682,7 @@ static void drop_netconsole_target(struct config_group *group,
 	.drop_item	= drop_netconsole_target,
 };
 
-static struct config_item_type netconsole_subsys_type = {
+static const struct config_item_type netconsole_subsys_type = {
 	.ct_group_ops	= &netconsole_subsys_group_ops,
 	.ct_owner	= THIS_MODULE,
 };
-- 
1.9.1
