From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/3] net/sched: cls_flower: Add ports masks
Date: Thu, 15 Sep 2016 15:28:21 +0300
Message-ID: <1473942504-23216-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42760 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1765721AbcIOM2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:28:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series adds the ability to specify tcp/udp ports masks 
for TC/flower filter matches.

I also removed an unused fields from the flower keys struct 
and clarified the format of the recently added vlan attibutes.

Or.

v1--> v2 changes: 

 * fixes typo in patch #2 title and change log (Sergei)
 * added acks provided by Jiri on v1
 
FWIW, by mistake the cover letter of V1 (but not the patches)
carried V2 tag, hope this doesn't create too much confusion.

Or Gerlitz (3):
  net/sched: cls_flower: Support masking for matching on tcp/udp ports
  net/sched: cls_flower: Remove an unused field from the filter key structure
  net/sched: cls_flower: Specify vlan attributes format in the UAPI header

 include/uapi/linux/pkt_cls.h | 10 +++++++---
 net/sched/cls_flower.c       | 21 ++++++++++++---------
 2 files changed, 19 insertions(+), 12 deletions(-)

-- 
2.3.7
