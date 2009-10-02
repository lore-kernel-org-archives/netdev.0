From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: [PATCH 3/8] connector/dm: Fixed a compilation warning
Date: Fri,  2 Oct 2009 14:40:06 +0200
Message-ID: <1254487211-11810-4-git-send-email-philipp.reisner@linbit.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
 <1254487211-11810-2-git-send-email-philipp.reisner@linbit.com>
 <1254487211-11810-3-git-send-email-philipp.reisner@linbit.com>
Cc: dm-devel@redhat.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev-devel@lists.sourceforge.net,
	Philipp Reisner <philipp.reisner@linbit.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail09.linbit.com ([212.69.161.110]:53798 "EHLO
	mail09.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756786AbZJBMkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 08:40:10 -0400
In-Reply-To: <1254487211-11810-3-git-send-email-philipp.reisner@linbit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
Acked-by: Lars Ellenberg <lars.ellenberg@linbit.com>
Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
---
 drivers/md/dm-log-userspace-transfer.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
index 556131f..1327e1a 100644
--- a/drivers/md/dm-log-userspace-transfer.c
+++ b/drivers/md/dm-log-userspace-transfer.c
@@ -129,9 +129,8 @@ static int fill_pkg(struct cn_msg *msg, struct dm_ulog_request *tfr)
  * This is the connector callback that delivers data
  * that was sent from userspace.
  */
-static void cn_ulog_callback(void *data, struct netlink_skb_parms *nsp)
+static void cn_ulog_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
-	struct cn_msg *msg = (struct cn_msg *)data;
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
 
 	spin_lock(&receiving_list_lock);
-- 
1.6.0.4

