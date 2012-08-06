From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/2] Add device tree support for davinci_mdio driver and fix
 cpsw DT binding documentation
Date: Mon, 6 Aug 2012 20:35:56 +0530
Message-ID: <1344265558-5724-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, devicetree-discuss@lists.ozlabs.org,
 linux-omap@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch set adds support for device tree for Davinci MDIO driver and fixes
CPSW DT binding documentation to make it copy pastable to dts file.

This patch set is tested with the following git tree on AM335X Beagle Bone
https://github.com/hvaibhav/am335x-linux/tree/am335x-upstream-staging-cpsw

Mugunthan V N (2):
  drivers: net: ethernet: davince_mdio: device tree implementation
  documentation: dt: bindings: cpsw: fixing the examples for directly
    using it in dts file

 Documentation/devicetree/bindings/net/cpsw.txt     |  101 ++++++++++---------
 .../devicetree/bindings/net/davinci-mdio.txt       |   33 +++++++
 drivers/net/ethernet/ti/davinci_mdio.c             |   41 +++++++-
 3 files changed, 123 insertions(+), 52 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/davinci-mdio.txt
