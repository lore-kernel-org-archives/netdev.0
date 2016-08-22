From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 0/2] tc: flower, m_vlan: Introduce vlan tag support
Date: Mon, 22 Aug 2016 13:24:52 +0300
Message-ID: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49745 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754711AbcHVKZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:25:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Re-sending becuase of a wrong source e-mail address sent before.

This patchset introduce vlan tag support to the tc flower classifier.
In addition to adding vlan priority to vlan push action.

- The first patch adds classification according to vlan id and vlan priority to the flower.
- The second patch adds support for vlan priority to the current vlan push action.

Hadar Hen Zion (2):
  tc: flower: Introduce vlan support
  tc: m_vlan: Add priority option to push vlan action

 include/linux/pkt_cls.h        |  5 +++
 include/linux/tc_act/tc_vlan.h |  4 +++
 man/man8/tc-flower.8           | 25 ++++++++++++-
 man/man8/tc-vlan.8             |  5 +++
 tc/f_flower.c                  | 80 ++++++++++++++++++++++++++++++++++++++++--
 tc/m_vlan.c                    | 22 +++++++++++-
 6 files changed, 136 insertions(+), 5 deletions(-)

-- 
1.8.3.1
