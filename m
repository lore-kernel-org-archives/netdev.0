From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 0/2] 6lowpan: fragmentation fixes
Date: Mon,  2 Jun 2014 13:21:56 +0200
Message-ID: <1401708118-16436-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de,
	werner@almesberger.net, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:58719 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbaFBLWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 07:22:14 -0400
Received: by mail-wg0-f52.google.com with SMTP id l18so4879667wgh.11
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 04:22:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fix the 6LoWPAN fragmentation which are in two cases broken.

The first case is if we have exactly two 6LoWPAN fragments only. This is fixed
by patch "6lowpan_rtnl: fix fragmentation with two fragments".
The second case is a off by one issue if we have payload which hits the fragment
boundary.

Both issues are introduced by commit d4b2816d67d6e07b2f27037f282d8db03a5829d7
("6lowpan: fix fragmentation").

Alexander Aring (2):
  6lowpan_rtnl: fix fragmentation with two fragments
  6lowpan_rtnl: fix off by one while fragmentation

 net/ieee802154/6lowpan_rtnl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
1.9.3
