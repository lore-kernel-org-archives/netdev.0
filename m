From: Arthur Jones <ajones@riverbed.com>
Subject: [next-next PATCH] e1000e: fixup merge error
Date: Fri, 20 Mar 2009 08:24:47 -0700
Message-ID: <20090320152447.GA28023@ajones-laptop.nbttech.com>
References: <20090320.013141.243957487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	Arthur Jones <Arthur.Jones@riverbed.com>,
	<shemminger@vyatta.com>,
	"alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:51731 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731AbZCTPYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 11:24:50 -0400
Content-Disposition: inline
In-Reply-To: <20090320.013141.243957487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When merging into Jeff's tree:

	commit 5f66f208064f083aab5e55935d0575892e033b59
	Author: Arthur Jones <ajones@riverbed.com>
	Date:   Thu Mar 19 01:13:08 2009 +0000

	    e1000e: allow tx of pre-formatted vlan tagged packets

We lost one line, this fixes that missing
piece...

Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d092eaf..f388a01 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3774,7 +3774,7 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 	else
 		protocol = skb->protocol;
 
-	switch (skb->protocol) {
+	switch (protocol) {
 	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
-- 
1.5.6.3
