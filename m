From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 3/6] hid: make device_attribute const
Date: Mon, 21 Aug 2017 17:13:09 +0530
Message-ID: <1503315792-14837-4-git-send-email-bhumirks@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32944 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753675AbdHULoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 07:44:13 -0400
In-Reply-To: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make this const as it is only passed as an argument to the
function device_create_file and device_remove_file and the corresponding
arguments are of type const.
Done using Coccinelle

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/hid/hid-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/hid/hid-core.c b/drivers/hid/hid-core.c
index 9bc9116..24e929c 100644
--- a/drivers/hid/hid-core.c
+++ b/drivers/hid/hid-core.c
@@ -1662,7 +1662,7 @@ static bool hid_hiddev(struct hid_device *hdev)
 	.size = HID_MAX_DESCRIPTOR_SIZE,
 };
 
-static struct device_attribute dev_attr_country = {
+static const struct device_attribute dev_attr_country = {
 	.attr = { .name = "country", .mode = 0444 },
 	.show = show_country,
 };
-- 
1.9.1
