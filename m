From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/4] Tx time stamp advertising for four drivers
Date: Sun, 22 Jul 2012 19:15:38 +0200
Message-ID: <cover.1342976654.git.richardcochran__23626.6294647523$1342977404$gmane$org@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49372 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab2GVRPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 13:15:53 -0400
Received: by weyx8 with SMTP id x8so3753300wey.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 10:15:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series updates the ethtool code for four drivers that recently
add the skb_tx_timestamp hook. Since these drivers now support
software transmit time stamps, let us also advertise this via ethtool.

Thanks,
Richard

Richard Cochran (4):
  bnx2x: advertise transmit time stamping
  e1000: advertise transmit time stamping
  e1000e: advertise transmit time stamping
  forcedeth: advertise transmit time stamping

 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    1 +
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |    1 +
 drivers/net/ethernet/intel/e1000e/ethtool.c        |    1 +
 drivers/net/ethernet/nvidia/forcedeth.c            |    1 +
 4 files changed, 4 insertions(+), 0 deletions(-)

-- 
1.7.2.5
