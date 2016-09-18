From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH net-next 0/2] act_vlan: Introduce TCA_VLAN_ACT_MODIFY vlan action
Date: Sun, 18 Sep 2016 17:33:43 +0300
Message-ID: <1474209225-23665-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33530 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754132AbcIROeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 10:34:01 -0400
Received: by mail-wm0-f68.google.com with SMTP id w84so3851706wmg.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 07:34:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCA_VLAN_ACT_MODIFY allows one to change an existing tag.

It accepts same attributes as TCA_VLAN_ACT_PUSH (protocol, id,
priority).
If packet is vlan tagged, then the tag gets overwritten according to
user specified attributes.

For example, this allows user to replace a tag's vid while preserving
its priority bits (as opposed to "action vlan pop pipe action vlan push").

Shmulik Ladkani (2):
  net: skbuff: Export __skb_vlan_pop
  net/sched: act_vlan: Introduce TCA_VLAN_ACT_MODIFY vlan action

 include/linux/skbuff.h              |  1 +
 include/uapi/linux/tc_act/tc_vlan.h |  1 +
 net/core/skbuff.c                   |  7 +++++--
 net/sched/act_vlan.c                | 29 ++++++++++++++++++++++++++++-
 4 files changed, 35 insertions(+), 3 deletions(-)

-- 
2.7.4
