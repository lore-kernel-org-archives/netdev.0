From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 0/3] update ifstat for new stats
Date: Thu, 24 Nov 2016 16:12:37 +0200
Message-ID: <1479996760-61271-1-git-send-email-nogahf@mellanox.com>
Cc: eladr@mellanox.com, yotamg@mellanox.com, jiri@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43436 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965524AbcKXOLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 09:11:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously stats were gotten by RTM_GETLINK which return 32 bits based
statistics. It support only one type of stats.
Lately, a new method to get stats was added - RTM_GETSTATS. It supports
ability to choose stats type. The basic stats were changed from 32 bits
based to 64 bits based.

This patchset change ifstat to the new method, add it the ability to
choose an extended type of statistic, and add the extended type of SW
stats for packets that hit cpu.

Nogah Frankel (3):
  ifstat: Change interface to get stats
  ifstat: Add extended statistics to ifstat
  ifstat: Add "sw only" extended statistics to ifstat

 misc/ifstat.c | 125 +++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 102 insertions(+), 23 deletions(-)

-- 
2.4.3
