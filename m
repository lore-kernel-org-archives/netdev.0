From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 4/6] qlogic:  make device_attribute const
Date: Mon, 21 Aug 2017 17:13:10 +0530
Message-ID: <1503315792-14837-5-git-send-email-bhumirks@gmail.com>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, rjw@rjwysocki.net, lenb@kernel.org,
        jbacik@fb.com, jikos@kernel.org, benjamin.tissoires@redhat.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        cascardo@holoscopio.com, don@syst.com.br, dvhart@infradead.org,
        andy@infradead.org, sre@kernel.org, linux-acpi@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org,
        nbd-general@lists.sourceforge.net, linux-input@vger.kernel.org,
        netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
        linux-pm@vger.kernel.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only passed as an argument to the
function device_create_file and device_remove_file and the corresponding
arguments are of type const.
Done using Coccinelle

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c    | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 827de83..f2e8de6 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2828,7 +2828,7 @@ static void netxen_nic_poll_controller(struct net_device *netdev)
 	return sprintf(buf, "%d\n", bridged_mode);
 }
 
-static struct device_attribute dev_attr_bridged_mode = {
+static const struct device_attribute dev_attr_bridged_mode = {
        .attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
        .show = netxen_show_bridged_mode,
        .store = netxen_store_bridged_mode,
@@ -2860,7 +2860,7 @@ static void netxen_nic_poll_controller(struct net_device *netdev)
 			!!(adapter->flags & NETXEN_NIC_DIAG_ENABLED));
 }
 
-static struct device_attribute dev_attr_diag_mode = {
+static const struct device_attribute dev_attr_diag_mode = {
 	.attr = {.name = "diag_mode", .mode = (S_IRUGO | S_IWUSR)},
 	.show = netxen_show_diag_mode,
 	.store = netxen_store_diag_mode,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 82fcb83..287d89d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -1174,19 +1174,19 @@ static ssize_t qlcnic_83xx_sysfs_flash_write_handler(struct file *filp,
 	return size;
 }
 
-static struct device_attribute dev_attr_bridged_mode = {
+static const struct device_attribute dev_attr_bridged_mode = {
        .attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
        .show = qlcnic_show_bridged_mode,
        .store = qlcnic_store_bridged_mode,
 };
 
-static struct device_attribute dev_attr_diag_mode = {
+static const struct device_attribute dev_attr_diag_mode = {
 	.attr = {.name = "diag_mode", .mode = (S_IRUGO | S_IWUSR)},
 	.show = qlcnic_show_diag_mode,
 	.store = qlcnic_store_diag_mode,
 };
 
-static struct device_attribute dev_attr_beacon = {
+static const struct device_attribute dev_attr_beacon = {
 	.attr = {.name = "beacon", .mode = (S_IRUGO | S_IWUSR)},
 	.show = qlcnic_show_beacon,
 	.store = qlcnic_store_beacon,
-- 
1.9.1
