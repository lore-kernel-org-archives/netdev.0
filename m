From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 0/3] Misc. fixes for cxgb4 and cxgb4vf driver
Date: Wed, 7 May 2014 18:01:01 +0530
Message-ID: <1399465864-17737-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dm@chelsio.com>, <leedom@chelsio.com>,
	<kumaras@chelsio.com>, <nirranjan@chelsio.com>,
	<santosh@chelsio.com>, Hariprasad Shenai <hariprasad@chelsio.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6922 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaEGM3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 08:29:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
This series of patch provides fixes for cxgb4 and cxgb4vf driver related to
rx checksum counter and decodes module type a bit more for ethtool output.

The patches series is created against David Miller's 'net-next' tree.

We would like to request this patch series to get merged via David Miller's
'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Thanks

Hariprasad Shenai (3):
  cxgb4: Decode the firmware port and module type a bit more for ethtool
  cxgb4: Check if rx checksum offload is enabled, while reading hardware
    calculated checksum
  cxgb4vf: Check if rx checksum offload is enabled, while reading
    hardware calculated checksum

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 15 +++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  6 +++---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |  7 ++++---
 3 files changed, 18 insertions(+), 10 deletions(-)

-- 
1.8.4
