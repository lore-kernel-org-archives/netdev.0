From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 0/2] net: dsa: lan9303: Add fdb/mdb methods
Date: Wed, 18 Oct 2017 12:59:33 +0200
Message-ID: <20171018105935.12489-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series add support for accessing and managing the lan9303 ALR 
(Address Logic Resolution). 

The first patch add low level functions for accessing the ALR, along
with port_fast_age and port_fdb_dump methods.

The second patch add functions for managing ALR entires, along with
remaining fdb/mdb methods. 

Note I have have a question in the second patch, in lan9303_alr_del_port.

Note that to complete STP support, a special ALR entry with the STP eth
address must be added too. This must be addressed later.

Comments welcome!

Egil Hjelmeland (2):
  net: dsa: lan9303: Add port_fast_age and port_fdb_dump methods
  net: dsa: lan9303: Add fdb/mdb manipulation

 drivers/net/dsa/lan9303-core.c | 334 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |  11 ++
 2 files changed, 345 insertions(+)

-- 
2.11.0
