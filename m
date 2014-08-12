From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/3] sunvnet: Fixes to avoid soft lockup
Date: Tue, 12 Aug 2014 10:26:17 -0400
Message-ID: <20140812142617.GG2404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com, davem@davemloft.net,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20169 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaHLO0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 10:26:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The following patchset contains fixes for various sources of
soft lockup in the sunvnet driver. 

Sowmini Varadhan (3):
  sunvnet: Do not ask for an ACK for every dring transmit
  sunvnet: Do not spin in an infinite loop when vio_ldc_send() returns EAGAIN
  sunvnet: Schedule maybe_tx_wakeup as a tasklet from ldc_rx path

 drivers/net/ethernet/sun/sunvnet.c | 79 ++++++++++++++++++++++++++++----------
 drivers/net/ethernet/sun/sunvnet.h |  4 ++
 2 files changed, 62 insertions(+), 21 deletions(-)

-- 
1.8.4.2
