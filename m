From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 0/4] drivers: net: xgene-v2: Add MDIO and ethtool
 support
Date: Tue, 21 Mar 2017 18:18:01 -0700
Message-ID: <1490145485-32661-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
 f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch set,
    
- adds phy management and ethtool support
- fixes ethernet reset
- addresses review comments from previous patch set

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
v2: Address review comments from v1
	- removed mdio_lock, since there is a top level lock in mdio_bus.c

v1:
	- Initial version
---

Iyappan Subramanian (4):
  drivers: net: xgene-v2: Add MDIO support
  drivers: net: xgene-v2: Add ethtool support
  drivers: net: xgene-v2: Fix port reset
  drivers: net: xgene-v2: misc fixes

 drivers/net/ethernet/apm/xgene-v2/Makefile  |   2 +-
 drivers/net/ethernet/apm/xgene-v2/enet.c    |  24 +++-
 drivers/net/ethernet/apm/xgene-v2/enet.h    |   2 +
 drivers/net/ethernet/apm/xgene-v2/ethtool.c | 121 ++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/mac.c     |   2 +-
 drivers/net/ethernet/apm/xgene-v2/mac.h     |   2 +-
 drivers/net/ethernet/apm/xgene-v2/main.c    |  67 +++++------
 drivers/net/ethernet/apm/xgene-v2/main.h    |   5 +
 drivers/net/ethernet/apm/xgene-v2/mdio.c    | 167 ++++++++++++++++++++++++++++
 9 files changed, 351 insertions(+), 41 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ethtool.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mdio.c

-- 
1.9.1
