From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/2] net/sched: cls_flower: Support matching on ICMP
Date: Fri,  2 Dec 2016 19:05:49 +0100
Message-ID: <1480701951-3686-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35759 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbcLBSGI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:06:08 -0500
Received: by mail-wm0-f54.google.com with SMTP id a197so24421377wmd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:06:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series add supports for matching on ICMP type and code to cls_flower.
This is modeled on existing support for matching on L4 ports. The updates
to the dissector are intended to allow for code and storage re-use.

Change since RFC:
* Drop RFC designation after positive review from Jiri


Simon Horman (2):
  flow dissector: ICMP support
  net/sched: cls_flower: Support matching on ICMP type and code

 drivers/net/bonding/bond_main.c |  6 +++--
 include/linux/skbuff.h          |  5 +++++
 include/net/flow_dissector.h    | 50 ++++++++++++++++++++++++++++++++++++++---
 include/uapi/linux/pkt_cls.h    | 10 +++++++++
 net/core/flow_dissector.c       | 34 +++++++++++++++++++++++++---
 net/sched/cls_flow.c            |  4 ++--
 net/sched/cls_flower.c          | 42 ++++++++++++++++++++++++++++++++++
 7 files changed, 141 insertions(+), 10 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
