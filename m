From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/3] net/sched: cls_flower: Add ports masks
Date: Tue, 13 Sep 2016 17:02:38 +0300
Message-ID: <1473775361-16547-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36269 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751633AbcIMOCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 10:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds the ability to specify tcp/udp ports masks 
for TC/flower filter matches.

I also removed an unused fields from the flower keys struct 
and clarified the format of the recently added vlan attibutes.

Or.

Or Gerlitz (3):
  net/sched: cls_flower: Support masking for matching on tcp/udp ports
  net/sched: cls_flower: Remove an unsed field from the filter key structure
  net/sched: cls_flower: Specify vlan attributes format in the UAPI header

 include/uapi/linux/pkt_cls.h | 10 +++++++---
 net/sched/cls_flower.c       | 21 ++++++++++++---------
 2 files changed, 19 insertions(+), 12 deletions(-)

-- 
2.3.7
