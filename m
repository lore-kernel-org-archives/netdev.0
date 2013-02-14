From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v1 0/7] Fix, cleanup, optimize gfar_private and the Rx path
Date: Thu, 14 Feb 2013 17:00:00 +0200
Message-ID: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:57635 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754317Ab3BNPAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:00:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
  "David S. Miller" <davem@davemloft.net>


Hi Dave,
These patches went already through a review round with Paul.
Changes since the initial version of the patches:
* split the 1st patch into two patches (01 & 02, as suggested by Paul)
* added the suggested trivial cleanup patch:
  gianfar: gfar_process_frame returns void
* provided "long logs" with detailed comments and explanations

Thank you.

Regards,
Claudiu


Claudiu Manoil (7):
  gianfar: Remove unused device_node ref in gfar_private
  gianfar: Add device ref (dev) in gfar_private
  gianfar: Cleanup and optimize struct gfar_private
  gianfar: GRO_DROP is unlikely
  gianfar: gfar_process_frame returns void
  gianfar: Remove wrong buffer size conditioning to VLAN h/w offload
  gianfar: Fix and cleanup Rx FCB indication

 drivers/net/ethernet/freescale/gianfar.c |   85 ++++++++++++---------------
 drivers/net/ethernet/freescale/gianfar.h |   96 +++++++++++++++--------------
 2 files changed, 88 insertions(+), 93 deletions(-)

-- 
1.7.7.4
