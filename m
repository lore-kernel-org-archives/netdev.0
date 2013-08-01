From: Joe Perches <joe@perches.com>
Subject: [PATCH V3 0/3] networking: Use ETH_ALEN where appropriate
Date: Thu,  1 Aug 2013 16:17:46 -0700
Message-ID: <cover.1375398692.git.joe@perches.com>
References: <20130801.143137.331385226409040561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netfilter-devel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130801.143137.331385226409040561.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Convert the uses mac addresses to ETH_ALEN so
it's easier to find and verify where mac addresses
need to be __aligned(2)

Change in V2:
- Remove include/acpi/actbl2.h conversion
  It's a file copied from outside ACPI sources

Changes in V3:
- Don't move the pasemi_mac.h mac address to be aligned(2)
  Just note that it's unaligned.

Joe Perches (3):
  uapi: Convert some uses of 6 to ETH_ALEN
  include: Convert ethernet mac address declarations to use ETH_ALEN
  ethernet: Convert mac address uses of 6 to ETH_ALEN

 drivers/net/ethernet/8390/ax88796.c                |  4 +-
 drivers/net/ethernet/amd/pcnet32.c                 |  6 +--
 drivers/net/ethernet/broadcom/cnic_if.h            |  6 +--
 drivers/net/ethernet/dec/tulip/tulip_core.c        |  8 +--
 drivers/net/ethernet/i825xx/sun3_82586.h           |  4 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |  4 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           | 13 ++---
 drivers/net/ethernet/pasemi/pasemi_mac.h           |  2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |  4 +-
 drivers/net/ethernet/qlogic/qlge/qlge.h            |  2 +-
 include/linux/dm9000.h                             |  4 +-
 include/linux/fs_enet_pd.h                         |  3 +-
 include/linux/ieee80211.h                          | 59 +++++++++++-----------
 include/linux/mlx4/device.h                        | 11 ++--
 include/linux/mlx4/qp.h                            |  5 +-
 include/linux/mv643xx_eth.h                        |  3 +-
 include/linux/sh_eth.h                             |  3 +-
 include/linux/smsc911x.h                           |  3 +-
 include/linux/uwb/spec.h                           |  5 +-
 include/media/tveeprom.h                           |  4 +-
 include/net/irda/irlan_common.h                    |  3 +-
 include/uapi/linux/dn.h                            |  3 +-
 include/uapi/linux/if_bridge.h                     |  3 +-
 include/uapi/linux/netfilter_bridge/ebt_802_3.h    |  5 +-
 include/uapi/linux/netfilter_ipv4/ipt_CLUSTERIP.h  |  3 +-
 include/uapi/linux/virtio_net.h                    |  2 +-
 include/uapi/linux/wimax/i2400m.h                  |  4 +-
 28 files changed, 99 insertions(+), 79 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
