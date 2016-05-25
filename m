From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH 4.5-stable 0/2] net: vrf: 4.5 backports
Date: Wed, 25 May 2016 09:35:29 -0700
Message-ID: <1464194131-3457-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34586 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbcEYQfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 12:35:39 -0400
Received: by mail-pa0-f47.google.com with SMTP id qo8so19287430pab.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 09:35:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Backports of 2 vrf patches to 4.5.5 stable tree.

Dave: not sure if you want me to send to stable maintainers or if you
      want to add them to your stable queue. I have the 4.4.11 versions
      ready as well.

David Ahern (2):
  net: vrf: Fix dst reference counting
  net: vrf: protect changes to private data with rcu

 drivers/net/vrf.c       | 235 ++++++++++++------------------------------------
 include/net/ip6_route.h |   3 +
 include/net/route.h     |   3 +
 net/ipv4/route.c        |   7 +-
 net/ipv6/route.c        |   7 +-
 5 files changed, 71 insertions(+), 184 deletions(-)

-- 
2.1.4
