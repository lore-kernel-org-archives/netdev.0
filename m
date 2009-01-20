From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH REPOST 0/6] convert arm platforms to smsc911x
Date: Tue, 20 Jan 2009 13:28:28 +0000
Message-ID: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

This patchset, intended for 2.6.30, converts in-tree arm platforms from 
smc911x to the actively maintained smsc911x driver.

The platform updates (3-4) depend on the driver updates (1-2) for 
correct operation, so David Miller is planning to take these via the 
net-2.6 tree.  Defconfig updates have been split out (5-6) for merging 
via the arm tree.

Stanley Miao is taking care of the OMAP platform separately.

Steve Glendinning (6):
  smsc911x: add support for platform-specific irq flags
  smsc911x: register isr as IRQF_SHARED
  arm: convert pcm037 platform to use smsc911x
  arm: convert realview platform to use smsc911x
  arm: update pcm037 defconfig to use smsc911x
  arm: update realview defconfigs to use smsc911x

 arch/arm/configs/pcm037_defconfig       |   23 ++++++++++++++++++++++-
 arch/arm/configs/realview-smp_defconfig |   24 ++++++++++++++++++++++--
 arch/arm/configs/realview_defconfig     |   24 ++++++++++++++++++++++--
 arch/arm/mach-mx3/pcm037.c              |   22 ++++++++++++----------
 arch/arm/mach-realview/core.c           |   17 +++++++++--------
 drivers/net/smsc911x.c                  |   19 ++++++++++++++-----
 6 files changed, 101 insertions(+), 28 deletions(-)


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
