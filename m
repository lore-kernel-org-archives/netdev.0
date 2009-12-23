From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igbvf: Make igbvf error message more informative
Date: Wed, 23 Dec 2009 15:22:43 -0800
Message-ID: <20091223232243.16268.48056.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:38831
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751077AbZLWXXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:23:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index e9dd95f..0dbd032 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2763,7 +2763,8 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	err = hw->mac.ops.reset_hw(hw);
 	if (err) {
 		dev_info(&pdev->dev,
-		         "PF still in reset state, assigning new address\n");
+			 "PF still in reset state, assigning new address."
+			 " Is the PF interface up?\n");
 		random_ether_addr(hw->mac.addr);
 	} else {
 		err = hw->mac.ops.read_mac_addr(hw);

