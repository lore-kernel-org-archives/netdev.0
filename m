From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 0/3] net: time stamping fixes
Date: Thu, 13 Oct 2011 11:46:26 +0200
Message-ID: <cover.1318498805.git.richard.cochran@omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37737 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753524Ab1JMJqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 05:46:31 -0400
Received: by eye27 with SMTP id 27so1641047eye.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 02:46:30 -0700 (PDT)
In-Reply-To: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/core/timestamping.c   |    7 ++++++-
 4 files changed, 22 insertions(+), 5 deletions(-)

-- 
1.7.2.5
