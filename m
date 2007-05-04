From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/2] NetXen: Fix NetXen driver ping on system-p
Date: Fri, 4 May 2007 09:09:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705040907390.21891@dut46>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>, Rob Mapes <rob@netxen.com>,
	netxenproj@linsyssoft.com
To: netdev mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:3713 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1031065AbXEDQJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 12:09:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix for driver on System-p
This patch will fix a ping issue on system-p.

Signed-off by: Milan Bag <mbag@netxen.com>
Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
Signed-by: Mithlesh Thukral <mithlesh@netxen.com>

---

  drivers/net/netxen/netxen_nic_init.c |    2 +-
  1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index cf0e96a..a368924 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1216,7 +1216,7 @@ u32 netxen_process_rcv_ring(struct netxe
  		/* Window = 1 */
  		writel(consumer,
  		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[ctxid].
+					    recv_crb_registers[adapter->portnum].
  					    crb_rcv_status_consumer));
  	}

