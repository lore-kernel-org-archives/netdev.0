From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] cxgb4/cxgb4vf: Misc fixes and 40G support for cxgb4vf
Date: Thu,  9 Oct 2014 05:48:44 +0530
Message-ID: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59654
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752913AbaJIAOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 20:14:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds 40G support for cxgb4vf driver. Update the LSO length for
cxgb4vf, fix macro. Wait for device to get ready before reading PL_WHOAMI
register.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4/cxgb4vf: Updated the LSO transfer length in CPL_TX_PKT_LSO for
    T5
  cxgb4vf: Add 40G support for cxgb4vf driver
  cxgb4: Wait for device to get ready before reading any register

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    6 +++++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |    5 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   17 ++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |    5 ++---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   12 ++++++++----
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |    5 ++++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    6 ++++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   10 +++++++---
 10 files changed, 48 insertions(+), 21 deletions(-)
