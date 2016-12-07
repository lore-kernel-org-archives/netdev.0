From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v5 0/2] net/sched: cls_flower: Support matching on ICMP
Date: Wed,  7 Dec 2016 13:14:38 +0100
Message-ID: <1481112880-9801-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f170.google.com ([209.85.210.170]:33894 "EHLO
        mail-wj0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcLGMOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:14:48 -0500
Received: by mail-wj0-f170.google.com with SMTP id tg4so103600090wjb.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 04:14:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series adds support for matching on ICMP type and code to cls_flower.

Changes v4->v5:
* Drop all helpers

Changes v3->v4:
* Do not add icmp to struct flow_keys, it is not needed
* Do not test for ICMP protocols in packet in __skb_flow_dissect,
  this is also not needed

Changes v2->v3:
* Add FLOW_DISSECTOR_KEY_ICMP and use separate structure for ICMP

Changes v1->v2:
* Include all dissector helpers in first patch


Simon Horman (2):
  flow dissector: ICMP support
  net/sched: cls_flower: Support matching on ICMP type and code

 include/net/flow_dissector.h | 17 ++++++++++++++
 include/uapi/linux/pkt_cls.h | 10 +++++++++
 net/core/flow_dissector.c    | 31 ++++++++++++++++++++++++++
 net/sched/cls_flower.c       | 53 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 111 insertions(+)

-- 
2.7.0.rc3.207.g0ac5344
