From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 0/2] Add dest UDP port to IP tunnel parameters
Date: Tue, 13 Dec 2016 10:07:45 +0200
Message-ID: <1481616467-769-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49801 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932378AbcLMJDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 04:03:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance IP tunnel key classification and action parameters by adding
destination UDP port.

Thanks,
Hadar

Hadar Hen Zion (2):
  tc/cls_flower: Add dest UDP port to tunnel params
  tc/m_tunnel_key: Add dest UDP port to tunnel key action

 man/man8/tc-flower.8     |  8 +++++++-
 man/man8/tc-tunnel_key.8 |  6 ++++++
 tc/f_flower.c            | 25 +++++++++++++++++++++++++
 tc/m_tunnel_key.c        | 32 ++++++++++++++++++++++++++++++++
 4 files changed, 70 insertions(+), 1 deletion(-)

-- 
1.8.3.1
