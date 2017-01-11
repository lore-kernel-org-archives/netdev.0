From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 0/2] net/sched: cls_flower: Support matching ARP
Date: Wed, 11 Jan 2017 11:02:20 +0100
Message-ID: <1484128942-11745-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38546 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964959AbdAKKCs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 05:02:48 -0500
Received: by mail-wm0-f45.google.com with SMTP id r144so23140107wme.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 02:02:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for support matching on ARP operation, and hardware and
protocol addresses for Ethernet hardware and IPv4 protocol addresses.

Simon Horman (2):
  flow disector: ARP support
  net/sched: cls_flower: Support matching on ARP

 include/net/flow_dissector.h | 19 +++++++++++++++
 include/uapi/linux/pkt_cls.h | 11 +++++++++
 net/core/flow_dissector.c    | 57 ++++++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_flower.c       | 51 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 138 insertions(+)

-- 
2.7.0.rc3.207.g0ac5344
