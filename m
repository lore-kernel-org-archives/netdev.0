From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 0/2] Fix the usage of TC tunnel key
Date: Thu, 22 Dec 2016 10:14:39 +0200
Message-ID: <1482394481-19624-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34903 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1765054AbcLVJK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 04:10:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dest UDP port parameter to the usage of tc tunnle key action and
classifcation.


Hadar Hen Zion (2):
  tc/cls_flower: Add to the usage encapsulation dest UDP port
  tc/m_tunnel_key: Add to the usage encapsulation dest UDP port

 tc/f_flower.c     | 5 +++--
 tc/m_tunnel_key.c | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

-- 
1.8.3.1
