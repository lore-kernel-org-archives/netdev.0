From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/2] net/sched: cls_flower: Support matching ARP
Date: Wed, 11 Jan 2017 14:05:41 +0100
Message-ID: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35928 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966401AbdAKNGM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 08:06:12 -0500
Received: by mail-wm0-f49.google.com with SMTP id c85so157393352wmi.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 05:06:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for support matching on ARP operation, and hardware and
protocol addresses for Ethernet hardware and IPv4 protocol addresses.

Changes since RFC:
* None other than dropping RFC designation after positive feedback from Jiri

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
