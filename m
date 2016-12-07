From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v4 0/2] net/sched: cls_flower: Support matching on ICMP
Date: Wed,  7 Dec 2016 12:34:10 +0100
Message-ID: <1481110452-3129-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f174.google.com ([209.85.210.174]:34664 "EHLO
        mail-wj0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbcLGLeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 06:34:25 -0500
Received: by mail-wj0-f174.google.com with SMTP id tg4so102679361wjb.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 03:34:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series adds support for matching on ICMP type and code to cls_flower.

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

 include/net/flow_dissector.h | 30 +++++++++++++++++++++++++++
 include/uapi/linux/pkt_cls.h | 10 +++++++++
 net/core/flow_dissector.c    | 31 ++++++++++++++++++++++++++++
 net/sched/cls_flower.c       | 49 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 120 insertions(+)

-- 
2.7.0.rc3.207.g0ac5344
