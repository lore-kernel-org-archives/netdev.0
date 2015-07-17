From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4 DCB updates
Date: Fri, 17 Jul 2015 13:12:29 -0700
Message-ID: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10754 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752427AbbGQUMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:12:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset covers changes to work better with  the userspace
tools cgdcbxd and cgrulesengd and improves firmware support for
host-managed mode.

Also exports traffic class information that was previously not being
exported via dcbnl_ops and unfifies how app selector information is passed
to firmware.

Anish Bhatt (4):
  cxgb4 : Only pass app selector of 0 or 3 to firmware
  cxgb4 : Allow firmware DCB info to be queried in host state
  cxgb4 : Fill in number of DCB traffic classes supported
  cxgb4 : Fill DCB priority in vlan control headers

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 42 ++++++++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/sge.c       | 14 ++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h    |  3 ++
 3 files changed, 42 insertions(+), 17 deletions(-)

-- 
2.4.6
