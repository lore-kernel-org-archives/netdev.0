From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v3 0/2] net/sched: cls_flower: Support matching on ICMP
Date: Wed,  7 Dec 2016 10:41:35 +0100
Message-ID: <1481103697-19835-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38676 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752911AbcLGJmJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:42:09 -0500
Received: by mail-wm0-f43.google.com with SMTP id f82so157444319wmf.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 01:42:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series adds support for matching on ICMP type and code to cls_flower.

Changes v2->v3:
* Add FLOW_DISSECTOR_KEY_ICMP and use separate structure for ICMP

Changes v1->v2:
* Include all dissector helpers in first patch

Simon Horman (2):
  flow dissector: ICMP support
  net/sched: cls_flower: Support matching on ICMP type and code

 include/net/flow_dissector.h | 55 +++++++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/pkt_cls.h | 10 ++++++++
 net/core/flow_dissector.c    | 49 +++++++++++++++++++++++++++++++++------
 net/sched/cls_flower.c       | 49 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 155 insertions(+), 8 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
