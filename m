From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/3] ptp: feature enhancements
Date: Tue, 20 Sep 2011 13:43:13 +0200
Message-ID: <cover.1316518332.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f52.google.com ([209.85.215.52]:36491 "EHLO
	mail-ew0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111Ab1ITLnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 07:43:00 -0400
Received: by ewy19 with SMTP id 19so172762ewy.11
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2011 04:42:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds one driver specific enhancement and one new feature
to the PTP Hardware Clock subsystem. The first patch enables more of
the phyter's IO capabilities. The second patch introduces PTP one-step
support for Sync messages at the driver level. The third patch
implements the one-step flag in the phyter.

Richard Cochran (3):
  dp83640: enable six external events and one periodic output
  net: introduce ptp one step time stamp mode for sync packets
  dp83640: add time stamp insertion for sync messages

 drivers/net/phy/dp83640.c  |  205 +++++++++++++++++++++++++++++++++++++-------
 include/linux/net_tstamp.h |    9 ++
 2 files changed, 182 insertions(+), 32 deletions(-)

-- 
1.7.2.5
