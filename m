From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2 0/3]  net: time stamping fixes
Date: Fri, 21 Oct 2011 12:49:14 +0200
Message-ID: <cover.1319193734.git.richard.cochran@omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53783 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab1JUKtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 06:49:32 -0400
Received: by bkbzt19 with SMTP id zt19so4694404bkb.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 03:49:31 -0700 (PDT)
In-Reply-To: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ Changes in v2: use atomic_inc_not_zero per Eric's suggestion. ]

The first patch fixes a bug in the time stamping code introduced in
v2.6.36 of the kernel.

The other two patches depend on the first patch and fix two bugs in a
PTP Hardware Clock driver. This driver was first introduced in Linux
version 3.0.

Richard Cochran (3):
  net: hold sock reference while processing tx timestamps
  dp83640: use proper function to free transmit time stamping packets
  dp83640: free packet queues on remove

 drivers/net/phy/dp83640.c |   11 +++++++++--
 include/linux/phy.h       |    2 +-
 include/linux/skbuff.h    |    7 ++++++-
 net/core/timestamping.c   |   12 ++++++++++--
 4 files changed, 26 insertions(+), 6 deletions(-)

-- 
1.7.2.5
