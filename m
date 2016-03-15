From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 0/3] net/phy: Fixes for Cavium Thunder MDIO code.
Date: Mon, 14 Mar 2016 17:30:36 -0700
Message-ID: <1458001839-15993-1-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
 linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org,
 Florian Fainelli <f.fainelli@gmail.com>,
 Robert Richter <rric@kernel.org>, Sunil Goutham <sgoutham@cavium.com>
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

From: David Daney <david.daney@cavium.com>

Previous patch set:
commit 5fc7cf179449 ("net: thunderx: Cleanup PHY probing code.")
commit 1eefee901fca ("phy: mdio-octeon: Refactor into two files/modules")
commit 379d7ac7ca31 ("phy: mdio-thunder: Add driver for Cavium Thunder SoC MDIO buses.")

Had several problems.  We try to fix them here.


David Daney (3):
  phy: mdio-cavium: Add missing MODULE_* annotations.
  net: cavium: For Kconfig THUNDER_NIC_BGX, select MDIO_THUNDER.
  net: thunderx: Don't leak phy device references on -EPROBE_DEFER
    condition.

 drivers/net/ethernet/cavium/Kconfig               |  2 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 26 +++++++++++++++++------
 drivers/net/phy/mdio-cavium.c                     |  4 ++++
 3 files changed, 25 insertions(+), 7 deletions(-)

-- 
1.7.11.7
