From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/10] Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:23 -0800
Message-ID: <cover.1289855436.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jiri Kosina <trivial@kernel.org>
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Joe Perches (10):
  drivers/isdn/i4l: Remove unnecessary casts of netdev_priv
  drivers/net/bonding: Remove unnecessary casts of netdev_priv
  drivers/net/pcmcia: Remove unnecessary casts of netdev_priv
  drivers/net/qla3xxx.c: Remove unnecessary casts of netdev_priv
  drivers/net/qlge: Remove unnecessary casts of netdev_priv
  drivers/net/usb: Remove unnecessary casts of netdev_priv
  drivers/net/vxge: Remove unnecessary casts of netdev_priv
  drivers/net: Remove unnecessary casts of netdev_priv
  drivers/staging: Remove unnecessary casts of netdev_priv
  net/atm: Remove unnecessary casts of netdev_priv

 drivers/isdn/i4l/isdn_concap.c                     |    2 +-
 drivers/isdn/i4l/isdn_net.c                        |   20 ++++----
 drivers/isdn/i4l/isdn_ppp.c                        |   12 ++--
 drivers/net/ax88796.c                              |    8 ++--
 drivers/net/bonding/bond_3ad.c                     |    3 +-
 drivers/net/bonding/bonding.h                      |    2 +-
 drivers/net/dm9000.c                               |    2 +-
 drivers/net/iseries_veth.c                         |    2 +-
 drivers/net/lib8390.c                              |   24 ++++----
 drivers/net/ne-h8300.c                             |   12 ++--
 drivers/net/pcmcia/axnet_cs.c                      |   18 +++---
 drivers/net/qla3xxx.c                              |    8 ++--
 drivers/net/qlge/qlge_main.c                       |    8 ++--
 drivers/net/usb/pegasus.c                          |    4 +-
 drivers/net/vxge/vxge-ethtool.c                    |   26 +++++-----
 drivers/net/vxge/vxge-main.c                       |   26 +++++-----
 drivers/net/xilinx_emaclite.c                      |   20 ++++----
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_hw.c   |   54 ++++++++++----------
 drivers/staging/ft1000/ft1000-pcmcia/ft1000_proc.c |    8 ++--
 drivers/staging/ft1000/ft1000-usb/ft1000_chdev.c   |    8 ++--
 drivers/staging/ft1000/ft1000-usb/ft1000_hw.c      |   16 +++---
 drivers/staging/ft1000/ft1000-usb/ft1000_proc.c    |    6 +-
 drivers/staging/ft1000/ft1000-usb/ft1000_usb.c     |    2 +-
 drivers/staging/rtl8712/usb_intf.c                 |    2 +-
 net/atm/br2684.c                                   |    2 +-
 net/atm/lec.c                                      |    3 +-
 26 files changed, 148 insertions(+), 150 deletions(-)

-- 
1.7.3.1.g432b3.dirty
