From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/2] Expand Tx timestamping coverage by two drivers
Date: Sat, 10 Mar 2012 18:29:41 +0100
Message-ID: <cover.1331400160.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57944 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2CJR3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:29:48 -0500
Received: by wibhj6 with SMTP id hj6so1793497wib.1
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 09:29:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds SO_TIMESTAMPING in the transmit path for the Ethernet
MACs found in my older laptop and newer netbook.

Richard Cochran (2):
  r8169: enable transmit time stamping.
  e100: enable transmit time stamping.

 drivers/net/ethernet/intel/e100.c    |    2 ++
 drivers/net/ethernet/realtek/r8169.c |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

-- 
1.7.2.5
