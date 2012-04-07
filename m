From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 0/1] e100: support Tx timestamping
Date: Sat,  7 Apr 2012 14:49:45 +0200
Message-ID: <cover.1333802620.git.richardcochran@gmail.com>
References: <1333532088.3046.22.camel@jtkirshe-mobl>
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34079 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab2DGMt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 08:49:56 -0400
Received: by wgbdr13 with SMTP id dr13so2846715wgb.1
        for <netdev@vger.kernel.org>; Sat, 07 Apr 2012 05:49:55 -0700 (PDT)
In-Reply-To: <1333532088.3046.22.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in V2:
- Avoid time stamping of firmware blobs

This patch adds SO_TIMESTAMPING in the transmit path for the Ethernet
MACs found in my older laptop.


Richard Cochran (1):
  e100: enable transmit time stamping.

 drivers/net/ethernet/intel/e100.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

-- 
1.7.2.5
