From: Colin King <colin.king@canonical.com>
Subject: [PATCH] tap: make struct tap_fops static
Date: Sat, 12 Aug 2017 22:52:31 +0100
Message-ID: <20170812215231.6272-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Jason Wang <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Willem de Bruijn <willemb@google.com>,
        Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:52136 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdHLVwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 17:52:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The structure tap_fops is local to the source and does not need to
be in global scope, so make it static.

Cleans up sparse warning:
symbol 'tap_fops' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/tap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index ca267fd28ab8..0d039411e64c 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -1127,7 +1127,7 @@ static long tap_compat_ioctl(struct file *file, unsigned int cmd,
 }
 #endif
 
-const struct file_operations tap_fops = {
+static const struct file_operations tap_fops = {
 	.owner		= THIS_MODULE,
 	.open		= tap_open,
 	.release	= tap_release,
-- 
2.11.0
