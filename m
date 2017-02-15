From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 0/3] iplink: add support for link xstats
Date: Wed, 15 Feb 2017 15:23:10 +0100
Message-ID: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36953 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdBOOX1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:23:27 -0500
Received: by mail-wm0-f50.google.com with SMTP id v77so41556549wmv.0
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 06:23:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This set adds support for printing link xstats per link type. Currently
only the bridge and its ports support such call and it dumps the mcast
stats. This model makes it easy to use the same callback for both bridge
and bridge_slave link types. Patch 01 also updates the man page with the
new xstats link option and you can find an example in patch 02's commit
message.

Thanks,
 Nik


Nikolay Aleksandrov (3):
  iplink: add support for xstats subcommand
  iplink: bridge: add support for displaying xstats
  iplink: bridge_slave: add support for displaying xstats

 ip/Makefile              |   2 +-
 ip/ip_common.h           |  12 +++-
 ip/iplink.c              |   5 ++
 ip/iplink_bridge.c       | 153 +++++++++++++++++++++++++++++++++++++++++++++++
 ip/iplink_bridge_slave.c |   2 +
 ip/iplink_xstats.c       |  81 +++++++++++++++++++++++++
 man/man8/ip-link.8.in    |  12 ++++
 7 files changed, 264 insertions(+), 3 deletions(-)
 create mode 100644 ip/iplink_xstats.c

-- 
2.1.4
