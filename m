From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/4] add meminfo, bist status and misc. fixes
Date: Tue,  4 Aug 2015 14:36:16 +0530
Message-ID: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10197 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755138AbbHDDvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 23:51:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series adds the following.
Add support to dump memory address range of various hw modules
Add support to dump edc bist status during ecc error
Read correct bits of who am i register for T6 adapter
and update T6 register range

This patch series has been created against net-next tree and includes
patches on cxgb4 and cxgb4vf driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

V2: PATCH 3/4 ("cxgb4/cxgb4vf: read the correct bits of PL Who Am I
    register") Fix switch statement in get_chip_type() and some more style
    fixes based on review comment by Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Hariprasad Shenai (4):
  cxgb4: Add debugfs support to dump meminfo
  cxgb4: Add support to dump edc bist status
  cxgb4/cxgb4vf: read the correct bits of PL Who Am I register
  cxgb4: Update T6 register ranges

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 285 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  34 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  73 ++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 131 +++++++++-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   3 +-
 5 files changed, 506 insertions(+), 20 deletions(-)

-- 
2.3.4
