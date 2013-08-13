From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH 0/6] 6lowpan: uncompress of addresses fix
Date: Tue, 13 Aug 2013 23:53:27 +0200
Message-ID: <1376430813-30982-2-git-send-email-alex.aring@gmail.com>
References: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:48266 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758121Ab3HMVtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:49:50 -0400
Received: by mail-ea0-f177.google.com with SMTP id f15so4383640eak.22
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 14:49:49 -0700 (PDT)
In-Reply-To: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation to uncompress addresses in a 6lowpan header
is completely broken.

This patch series fixes the parsing of addresses in a 6lowpan header.
It contains a major rewrite of the uncompress address function to parse
the address in a correct way.

Alexander Aring (5):
  6lowpan: init ipv6hdr buffer to zero
  6lowpan: introduce lowpan_fetch_skb function
  6lowpan: add function to uncompress multicast addr
  6lowpan: lowpan_uncompress_addr with address_mode
  6lowpan: handle context based source address

David Hauweele (1):
  6lowpan: Fix fragmentation with link-local compressed addresses

 net/ieee802154/6lowpan.c | 284 +++++++++++++++++++++++++++++++----------------
 net/ieee802154/6lowpan.h |  20 +++-
 2 files changed, 203 insertions(+), 101 deletions(-)

-- 
1.8.3.3
