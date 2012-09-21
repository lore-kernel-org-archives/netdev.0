From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/1] for 3.6 - fix gianfar build failure
Date: Fri, 21 Sep 2012 07:11:11 +0200
Message-ID: <cover.1348203988.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62948 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab2IUFLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 01:11:23 -0400
Received: by weyx8 with SMTP id x8so1727597wey.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 22:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gianfar ethtool time stamping change doesn't even build. This
should really get fixed for 3.6 if at all possible.

Thanks,
Richard


Richard Cochran (1):
  gianfar: fix phc index build failure

 drivers/net/ethernet/freescale/gianfar_ethtool.c |    1 +
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

-- 
1.7.2.5
