From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 0/4] 6lowpan: cleanup header creation
Date: Wed, 30 Oct 2013 09:18:20 +0100
Message-ID: <1383121104-2515-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:62486 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab3J3ISh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 04:18:37 -0400
Received: by mail-ee0-f44.google.com with SMTP id c4so446552eek.3
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 01:18:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series cleanup the 6LoWPAN header creation and extend the use
of skb_*_header functions.

Patch 2/4 fix issues of parsing the mac header. The ieee802.15.4 header
has a dynamic size which depends on frame control bits. This patch replaces the
static mac header len calculation with a dynamic one.

Alexander Aring (4):
  6lowpan: remove unnecessary set of headers
  6lowpan: set and use mac_len for mac header length
  6lowpan: set 6lowpan network and transport header
  6lowpan: cleanup skb copy data

 net/ieee802154/6lowpan.c | 32 +++++++++++---------------------
 net/mac802154/wpan.c     |  2 ++
 2 files changed, 13 insertions(+), 21 deletions(-)

-- 
1.8.4.2
