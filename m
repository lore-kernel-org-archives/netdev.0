From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] [POWERPC] iSeries: fix section mismatch in iseries_veth
Date: Tue, 5 Feb 2008 14:19:40 +1100
Message-ID: <20080205141940.c6ddb479.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:44590 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbYBEDTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 22:19:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WARNING: vmlinux.o(.text+0x25dca0): Section mismatch in reference from the function .veth_probe() to the function .init.text:.veth_probe_one()

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/iseries_veth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Jeff, can this go in through the powerpc tree?

diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 419861c..58d3bb6 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1020,7 +1020,7 @@ static const struct ethtool_ops ops = {
 	.get_link = veth_get_link,
 };
 
-static struct net_device * __init veth_probe_one(int vlan,
+static struct net_device *veth_probe_one(int vlan,
 		struct vio_dev *vio_dev)
 {
 	struct net_device *dev;
-- 
1.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
