From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/4] Few l2 table related enhancements for cxgb4
Date: Wed, 16 Dec 2015 13:16:24 +0530
Message-ID: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:52735 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751846AbbLPHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 02:45:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This series adds a new API to allocate and update l2t entry, replaces
arpq_head/arpq_tail with double skb double linked list. Use t4_mgmt_tx()
to send control packets of l2t write request. Remove some magical values
used in calculating vlan priority.

This patch series has been created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (4):
  cxgb4: Use mask & shift while returning vlan_prio
  cxgb4: Add API to alloc l2t entry; also update existing ones
  cxgb4: Use t4_mgmt_tx() API for sending write l2t request ctrl
    packets.
  cxgb4: Replace arpq_head/arpq_tail with  SKB double link-list code

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  10 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        | 179 +++++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        |  10 +-
 3 files changed, 137 insertions(+), 62 deletions(-)

-- 
2.3.4
