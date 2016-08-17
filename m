From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] net: bridge: export vlan stats per-port with flags
Date: Wed, 17 Aug 2016 12:53:08 +0200
Message-ID: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38351 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcHQKx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:53:27 -0400
Received: by mail-wm0-f42.google.com with SMTP id o80so224343779wme.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 03:53:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This set adds the ability to export vlan stats per-port. Patch 01 makes
that possible by consolidating the bridge and port linkxstats calls. Then
patch 02 allows to dump the vlan entry flags in order to be able to
distinguish between bridge and port vlan entries when dumping the master
device vlan stats. That is needed because that call was implemented when
the stats API didn't have slave dumping capabilities and it dumps all vlan
stats (for both bridge and port entries). We also need it in order to print
the vlan flags when dumping the stats.

Cheers,
 Nik

Nikolay Aleksandrov (2):
  net: bridge: consolidate bridge and port linkxstats calls
  net: bridge: export vlan flags with the stats

 include/uapi/linux/if_bridge.h |   2 +-
 net/bridge/br_netlink.c        | 115 ++++++++++++++---------------------------
 2 files changed, 41 insertions(+), 76 deletions(-)

-- 
2.1.4
