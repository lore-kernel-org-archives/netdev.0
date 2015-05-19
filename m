From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 0/2] Remove dead code and replace byte-oder functions
Date: Tue, 19 May 2015 18:20:42 +0530
Message-ID: <1432039844-23326-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24527 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754250AbbESHi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 03:38:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series removes dead fn t4_read_edc and t4_read_mc, also replaces
ntoh{s,l} and hton{s,l} calls with the generic byteorder.

PATCH 2/2 was sent as a single PATCH, but had some byte-ordering issues
in t4_read_edc and t4_read_mc function. Found that t4_read_edc and
t4_read_mc is unused, so PATCH 1/2 is added to remove it.

This patch series is created against net-next tree and includes
patches on cxgb4 driver.

We have included all the maintainers of respective drivers. Kindly review
the change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (2):
  cxgb4: Remove dead function t4_read_edc and t4_read_mc
  cxgb4: replace ntoh{s,l} and hton{s,l} calls with the generic
    byteorder

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h |   4 -
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 509 ++++++++++++-----------------
 2 files changed, 217 insertions(+), 296 deletions(-)

-- 
2.3.4
