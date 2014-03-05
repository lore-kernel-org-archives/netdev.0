From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 0/2] 6lowpan: header cleanup
Date: Wed,  5 Mar 2014 14:29:03 +0100
Message-ID: <1394026145-18981-1-git-send-email-alex.aring@gmail.com>
Cc: gustavo@padovan.org, johan.hedberg@gmail.com, davem@davemloft.net,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:34602 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765AbaCEN3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 08:29:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series fix a missing include of 6LoWPAN header and move it
into the include/net directory. Since we did some code sharing with
bluetooth 6LoWPAN the header turns into a generic header for 6LoWPAN.
Instead to use a relative path in bluetooth 6LoWPAN we can now use
include <net/6lowpan.h>.

- Alex

Alexander Aring (2):
  6lowpan: add missing include of net/ipv6.h
  6lowpan: move 6lowpan header to include/net

 {net/ieee802154 => include/net}/6lowpan.h | 2 ++
 net/bluetooth/6lowpan.c                   | 2 +-
 net/ieee802154/6lowpan_iphc.c             | 3 +--
 net/ieee802154/6lowpan_rtnl.c             | 2 +-
 net/ieee802154/reassembly.c               | 2 +-
 5 files changed, 6 insertions(+), 5 deletions(-)
 rename {net/ieee802154 => include/net}/6lowpan.h (99%)

-- 
1.9.0
