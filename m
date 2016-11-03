From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 0/2] tc: flower: Support matching on SCTP ports
Date: Thu,  3 Nov 2016 13:26:39 +0100
Message-ID: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38260 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754647AbcKCM2F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:28:05 -0400
Received: by mail-wm0-f47.google.com with SMTP id n67so97797336wme.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:28:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series adds support for matching on SCTP ports in the same way
that matching on TCP and UDP ports is already supported. It corresponds to
a net-next patch to add the same support to the kernel.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ip parent ffff: \
    flower indev eth0 ip_proto sctp dst_port 80 \
    action drop


Simon Horman (2):
  tc: update headers for TCA_FLOWER_KEY_SCTP_*
  tc: flower: Support matching on SCTP ports

 include/linux/pkt_cls.h |  5 ++++
 tc/f_flower.c           | 65 +++++++++++++++++++++++--------------------------
 2 files changed, 36 insertions(+), 34 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
