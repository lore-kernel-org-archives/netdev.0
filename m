From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v3 0/5] 6lowpan: trivial changes
Date: Mon, 28 Oct 2013 10:24:15 +0100
Message-ID: <1382952260-23174-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:48373 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab3J1JY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 05:24:28 -0400
Received: by mail-ee0-f50.google.com with SMTP id l10so3216704eei.23
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 02:24:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series includes some trivial changes to prepare the 6lowpan stack
for upcomming patch-series which mainly fix fragmentation according to rfc4944
and udp handling(which is currently broken).

Changes since v3:
  - really fix intendation in patch 3/5

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
