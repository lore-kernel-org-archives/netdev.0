From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 0/3] Process IFLA_BRIDGE_VLAN_INFO tlv
Date: Fri,  8 Sep 2017 17:52:20 -0400
Message-ID: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35211 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752130AbdIHVwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:52:44 -0400
Received: by mail-io0-f194.google.com with SMTP id c69so1725682ioe.2
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:52:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Process IFLA_BRIDGE_VLAN_INFO attribute nested in IFLA_AF_SPEC, which
contains bridge vlan table per port passed in link events.

Roman Mashak (3):
  bridge: isolate vlans  parsing code in a separate API
  bridge: dump vlan table information for link
  bridge: request vlans along with link information

 bridge/br_common.h |   1 +
 bridge/link.c      |  23 +++++++--
 bridge/vlan.c      | 145 +++++++++++++++++++++++++++--------------------------
 3 files changed, 96 insertions(+), 73 deletions(-)

-- 
1.9.1
