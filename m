From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net 0/2] net/sched: cls_flower: Fix mask handling
Date: Wed, 14 Dec 2016 19:00:56 +0200
Message-ID: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44453 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753832AbcLNRID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 12:08:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
The series fix how the mask is being handled.
Thanks.

Paul Blakey (2):
  net/sched: cls_flower: Use mask for addr_type
  net/sched: cls_flower: Use masked key when calling HW offloads

 net/sched/cls_flower.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

-- 
1.8.3.1
