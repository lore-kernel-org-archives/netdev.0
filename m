From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCH 0/4] Add support for velocity network driver on platform
 devices
Date: Sun, 28 Apr 2013 15:16:42 +1200
Message-ID: <1367119006-31280-1-git-send-email-linux@prisktech.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vt8500-wm8505-linux-kernel@googlegroups.com, netdev@vger.kernel.org,
 Tony Prisk <linux@prisktech.co.nz>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Francois Romieu <romieu@fr.zoreil.com>
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

The first three patches are general tidyup.
Patch #1 just alphabetizes the #includes to make it easier to read.
Patch #2 replaces vptr->dev with vptr->netdev, again for clarity in the code.
Patch #3 replaces the pci dma functions with the generic versions.

I have build tested these patches but don't have a PCI velocity to run-test it.
I can't see that they should introduce any problems as it is all renames and
function swapping.

Patch #4 adds support for the velocity driver on devicetree platform devices.
Binding document included. This patch is compile-tested for PCI, and boot
tested on a VIA APC8750.

I think it would be pertinent to get some tested-by's for PCI users.

Regards
Tony Prisk


Tony Prisk (4):
  net: velocity: Alphabetize #includes
  net: velocity: Rename vptr->dev to vptr->netdev
  net: velocity: Convert to generic dma functions
  net: velocity: Add platform device support to VIA velocity driver

 .../devicetree/bindings/net/via-velocity.txt       |   20 +
 drivers/net/ethernet/via/Kconfig                   |    3 +-
 drivers/net/ethernet/via/via-velocity.c            |  612 ++++++++++++++------
 drivers/net/ethernet/via/via-velocity.h            |   35 +-
 4 files changed, 480 insertions(+), 190 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/via-velocity.txt

-- 
1.7.9.5
