From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] freescale: remove incorrect copied comment
Date: Fri, 17 Jul 2015 07:25:11 -0700
Message-ID: <1437143123-5031-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	<linuxppc-dev@lists.ozlabs.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19520 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757889AbbGQOZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:36 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The comment in question is word-for-word copied from ixgbe, and clearly
has no meaning in freescale's driver. (it even says 'return an error'
when the code clearly does not). Remove the comment as it is obviously
incorrect and not applicable to the code as it is today.

CC: Pantelis Antoniou <pantelis.antoniou@gmail.com>
CC: Vitaly Bordug <vbordug@ru.mvista.com>
CC: <linuxppc-dev@lists.ozlabs.org>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index a15663a..7a8386a 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -506,12 +506,6 @@ int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr)
 		break;
 
 	default:
-		/*
-		 * register RXMTRL must be set in order to do V1 packets,
-		 * therefore it is not possible to time stamp both V1 Sync and
-		 * Delay_Req messages and hardware does not support
-		 * timestamping all packets => return error
-		 */
 		fep->hwts_rx_en = 1;
 		config.rx_filter = HWTSTAMP_FILTER_ALL;
 		break;
-- 
2.4.3
