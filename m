From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 0/5] 6lowpan: trivial changes
Date: Sat, 26 Oct 2013 15:53:57 +0200
Message-ID: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:49941 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab3JZNyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 09:54:19 -0400
Received: by mail-ea0-f180.google.com with SMTP id l9so1015446eaj.39
        for <netdev@vger.kernel.org>; Sat, 26 Oct 2013 06:54:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series includes some trivial changes to prepare the 6lowpan stack
for upcomming patch-series which mainly fix fragmentation according to rfc4944
and udp handling(which is currently broken).

Changes since v2:
  - change intendation in patch 3/5
  - fix typo in 5/5 unecessary -> unnecessary
  - add missing 6lowpan tag in cover-letter

Alexander Aring (5):
  6lowpan: remove unnecessary ret variable
  6lowpan: remove unnecessary check on err >= 0
  6lowpan: use netdev_alloc_skb instead dev_alloc_skb
  6lowpan: remove skb->dev assignment
  6lowpan: remove unnecessary break

 net/ieee802154/6lowpan.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

-- 
1.8.4.1
