From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 0/6] 6lowpan: udp compression/uncompression fix
Date: Thu, 14 Nov 2013 16:48:46 +0100
Message-ID: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:35871 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab3KNPtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 10:49:04 -0500
Received: by mail-bk0-f41.google.com with SMTP id v15so1172202bkz.0
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 07:49:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current 6LoWPAN udp compression/uncompression is completely broken.
This patch series fix a lot of udp compression/uncompression issues and
add support parsing with lowpan_fetch_skb function.

Alexander Aring (6):
  6lowpan: fix udp nullpointer dereferencing
  6lowpan: fix udp compress ordering
  6lowpan: fix udp byte ordering
  6lowpan: add udp warning for elided checksum
  6lowpan: udp use lowpan_fetch_skb function
  6lowpan: udp use subtraction on both conditions

 net/ieee802154/6lowpan.c | 80 +++++++++++++++++++++++++-----------------------
 net/ieee802154/6lowpan.h |  1 +
 2 files changed, 43 insertions(+), 38 deletions(-)

-- 
1.8.4.2
