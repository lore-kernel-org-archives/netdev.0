From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 0/2]  net: dsa: lan9303: Add fdb/mdb methods
Date: Thu, 19 Oct 2017 14:10:13 +0200
Message-ID: <20171019121015.7395-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:46494 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752747AbdJSMKm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 08:10:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add support for accessing and managing the lan9303 ALR 
(Address Logic Resolution). 

The first patch add low level functions for accessing the ALR, along
with port_fast_age and port_fdb_dump methods.

The second patch add functions for managing ALR entires, along with
remaining fdb/mdb methods. 

Note that to complete STP support, a special ALR entry with the STP eth
address must be added too. This must be addressed later.

Comments welcome!

Changes v1 -> v2:
 - Patch 2: Removed question comment

Egil Hjelmeland (2):
  net: dsa: lan9303: Add port_fast_age and port_fdb_dump methods
  net: dsa: lan9303: Add fdb/mdb manipulation

 drivers/net/dsa/lan9303-core.c | 331 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |  11 ++
 2 files changed, 342 insertions(+)

-- 
2.11.0
