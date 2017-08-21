From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 6/6] power: supply: make device_attribute const
Date: Mon, 21 Aug 2017 17:13:12 +0530
Message-ID: <1503315792-14837-7-git-send-email-bhumirks@gmail.com>
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
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only passed as an argument to the
function device_create_file and device_remove_file and the corresponding
arguments are of type const.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/power/supply/olpc_battery.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/power/supply/olpc_battery.c b/drivers/power/supply/olpc_battery.c
index fc20ca3..3bc2eea 100644
--- a/drivers/power/supply/olpc_battery.c
+++ b/drivers/power/supply/olpc_battery.c
@@ -559,7 +559,7 @@ static ssize_t olpc_bat_error_read(struct device *dev,
 	return sprintf(buf, "%d\n", ec_byte);
 }
 
-static struct device_attribute olpc_bat_error = {
+static const struct device_attribute olpc_bat_error = {
 	.attr = {
 		.name = "error",
 		.mode = S_IRUGO,
-- 
1.9.1
