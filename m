From: mohun106@gmail.com
Subject: [PATCH 0/3] Add MDIO support to ThunderX NIC driver
Date: Mon, 27 Jul 2015 19:14:40 -0700
Message-ID: <1438049683-10630-1-git-send-email-mohun106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
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

From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>

This patch series adds MDIO support to ThunderX NIC driver by making use
of existing mdio-octeon driver. In the process modified the mdio-octeon
driver to work on both Octeon and ThunderX platforms.

Radha Mohan Chintakuntla (3):
  net: mdio-octeon: Modify driver to work on both ThunderX and Octeon
  net: mdio-octeon: Fix octeon_mdiobus_probe function for return values
  net: thunderx: Select CONFIG_MDIO_OCTEON for ThunderX NIC

 drivers/net/ethernet/cavium/Kconfig |    2 +
 drivers/net/phy/Kconfig             |    9 ++-
 drivers/net/phy/mdio-octeon.c       |  136 +++++++++++++++++++++++++++++------
 3 files changed, 122 insertions(+), 25 deletions(-)
