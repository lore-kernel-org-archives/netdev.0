From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] enic: fail when try to setup unsupported features
Date: Tue, 29 Jun 2010 16:33:52 +0200
Message-ID: <20100629163352.66e19265@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756159Ab0F2OeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 10:34:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/enic/enic_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6c6795b..77a7f87 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -365,7 +365,6 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
 	.get_flags = ethtool_op_get_flags,
-	.set_flags = ethtool_op_set_flags,
 };
 
 static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf *buf)
-- 
1.5.5.6

