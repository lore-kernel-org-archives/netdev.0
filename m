From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/2] cxgb4: Adds support for VF mgmt ndo's
Date: Wed, 24 Aug 2016 12:20:32 +0530
Message-ID: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:62960 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751568AbcHXGvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:51:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds support for ndo_set_vf_vlan and ndo_get_vf_config
for cxgb4 driver.

This patch series has been created against net-next tree.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4/cxgb4vf: Add support for ndo_set_vf_vlan
  cxgb4: Add support for ndo_get_vf_config

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   11 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   96 +++++++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   27 ++++++-
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    1 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |   15 +++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   28 ++++++
 8 files changed, 176 insertions(+), 5 deletions(-)

-- 
1.7.3
