From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next 0/3] tc: flower: Support matching on ICMP
Date: Fri,  2 Dec 2016 10:59:42 +0100
Message-ID: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f182.google.com ([209.85.210.182]:36223 "EHLO
        mail-wj0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbcLBJ74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 04:59:56 -0500
Received: by mail-wj0-f182.google.com with SMTP id qp4so227582514wjc.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 01:59:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for matching on ICMP type and code to flower. This is modeled
on existing support for matching on L4 ports.

The second patch provided a minor cleanup which is in keeping with
they style used in the last patch.

This is marked as an RFC to match the same designation given to the
corresponding kernel patches.

Based on iproute2/net-next with the following applied:
* [[PATCH iproute2/net-next v2] 0/4] tc: flower: SCTP and other port fixes

Simon Horman (3):
  tc: flower: update headers for TCA_FLOWER_KEY_ICMP*
  tc: flower: introduce enum flower_endpoint
  tc: flower: support matching on ICMP type and code

 include/linux/pkt_cls.h |  10 ++++
 man/man8/tc-flower.8    |  20 ++++++--
 tc/f_flower.c           | 118 ++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 129 insertions(+), 19 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
