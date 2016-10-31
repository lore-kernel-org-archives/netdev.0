From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/4] bridge: add support for PIM hello router ports
Date: Mon, 31 Oct 2016 13:21:01 +0100
Message-ID: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dwalton@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38474 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941390AbcJaMVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:21:18 -0400
Received: by mail-wm0-f47.google.com with SMTP id n67so225121461wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 05:21:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
The first 3 patches of this set do minor cleanups and add some helpers to
the PIM header file. Patch 4 adds a way to detect mcast router ports via
PIM hello messages, they're marked as temporary and are not considered for
querier. There's more detailed information in patch 4's commit message.

Thanks,
 Nik


Nikolay Aleksandrov (4):
  net: pim: add common pimhdr struct and helpers
  net: pim: add a helper to check for IPv4 all pim routers address
  net: pim: add all RFC7761 message types
  bridge: mcast: add router port on PIM hello message

 include/linux/pim.h       | 81 +++++++++++++++++++++++++++++++++++++++++------
 net/bridge/br_multicast.c | 22 ++++++++++++-
 net/ipv4/ipmr.c           |  2 +-
 net/ipv6/ip6mr.c          |  2 +-
 4 files changed, 95 insertions(+), 12 deletions(-)

-- 
2.1.4
