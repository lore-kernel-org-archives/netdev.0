From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 0/2] net/sched: cls_flower: Support matching ARP
Date: Thu, 12 Jan 2017 09:11:57 +0100
Message-ID: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36624 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdALIME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:12:04 -0500
Received: by mail-wm0-f49.google.com with SMTP id c85so9346980wmi.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:12:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for support matching on ARP operation, and hardware and
protocol addresses for Ethernet hardware and IPv4 protocol addresses.

Changes since RFC:
* Drop RFC designation; kernel patches are present in net-next

Simon Horman (2):
  tc: flower: update headers for TCA_FLOWER_KEY_ARP*
  tc: flower: Support matching ARP

 include/linux/pkt_cls.h |  11 +++
 man/man8/tc-flower.8    |  41 +++++++++-
 tc/f_flower.c           | 208 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 243 insertions(+), 17 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
