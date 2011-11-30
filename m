From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 1/2] net/hyperv: Fix long lines in netvsc.c
Date: Wed, 30 Nov 2011 07:19:07 -0800
Message-ID: <1322666348-6554-1-git-send-email-haiyangz@microsoft.com>
To: haiyangz@microsoft.com, kys@microsoft.com, davem@davemloft.net,
	gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@linuxdriverproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:41891
	"HELO p3plsmtps2ded02-01.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754893Ab1K3PTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 10:19:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 28e69a6..4a807e4 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -230,9 +230,11 @@ static int netvsc_init_recv_buf(struct hv_device *device)
 	net_device->recv_section_cnt = init_packet->msg.
 		v1_msg.send_recv_buf_complete.num_sections;
 
-	net_device->recv_section = kmemdup(init_packet->msg.v1_msg.send_recv_buf_complete.sections,
-					   net_device->recv_section_cnt * sizeof(struct nvsp_1_receive_buffer_section),
-					   GFP_KERNEL);
+	net_device->recv_section = kmemdup(
+		init_packet->msg.v1_msg.send_recv_buf_complete.sections,
+		net_device->recv_section_cnt *
+		sizeof(struct nvsp_1_receive_buffer_section),
+		GFP_KERNEL);
 	if (net_device->recv_section == NULL) {
 		ret = -EINVAL;
 		goto cleanup;
-- 
1.7.4.1
