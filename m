From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3 0/2] net: time stamping fixes
Date: Mon, 24 Oct 2011 19:55:30 +0200
Message-ID: <cover.1319478544.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51247 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab1JXRzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 13:55:41 -0400
Received: by bkbzt19 with SMTP id zt19so8488004bkb.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 10:55:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Changes in v3: omit accepted patch and fixup the dp83640 patches. ]

These two patches depend on commit da92b194 and fix two bugs in a
PTP Hardware Clock driver. This driver was first introduced in Linux
version 3.0.

Richard Cochran (2):
  dp83640: use proper function to free transmit time stamping packets
  dp83640: free packet queues on remove

 drivers/net/phy/dp83640.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

-- 
1.7.2.5
