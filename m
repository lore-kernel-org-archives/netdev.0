From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 V2 0/2] tc: flower, m_vlan: Introduce vlan tag support
Date: Thu,  1 Sep 2016 09:45:46 +0300
Message-ID: <1472712348-1415-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48837 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752625AbcIAGqU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:46:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduce vlan tag support to the tc flower classifier.
In addition to adding vlan priority to vlan push action.

- The first patch adds classification according to vlan id and vlan priority to the flower.
- The second patch adds support for vlan priority to the current vlan push action.

Changes from v1:
- Remove VLAN_PRIO_MASK and VLAN_VID_MASK defines from tc_vlan.h file


Hadar Hen Zion (2):
  tc: flower: Introduce vlan support
  tc: m_vlan: Add priority option to push vlan action

 man/man8/tc-flower.8 | 25 ++++++++++++++++-
 man/man8/tc-vlan.8   |  5 ++++
 tc/f_flower.c        | 78 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 tc/m_vlan.c          | 22 ++++++++++++++-
 4 files changed, 125 insertions(+), 5 deletions(-)

-- 
1.8.3.1
