From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 0/4] Part 1: unify return value of
	.ndo_set_mac_address if address is invalid
Date: Tue, 21 Feb 2012 13:07:48 +0100
Message-ID: <1329826072-14689-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	bridge@lists.linux-foundation.org, Casey Leedom <leedom@chelsio.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dimitris Michailidis <dm@chelsio.com>, Danny Kukawka <dkukawka@suse.de>,
	Michael Chan <mchan@broadcom.com>, Chris Metcalf <cmetcalf@tilera.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Olof Johansson <olof@lixom.net>, linux-usb@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jon Mason <jdmason@kudzu.us>, linux-driver@qlogic.com,
	Mark Einon <mark.einon@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>, Divy Le Ray <divy@chelsio.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Here a series of patches to unifiy the return value of 
.ndo_set_mac_address if the given address isn't valid. 
Return -EADDRNOTAVAIL as eth_mac_addr() and other 
.ndo_set_mac_address functions already do if is_valid_ether_addr() 
fails.

Other patches will follow if this set gets accepted.

The patches are against the net-next git tree.

Danny Kukawka (4):
  ethernet: unify return value of .ndo_set_mac_address if address is
    invalid
  mcs7830: unify return value of .ndo_set_mac_address if address is
    invalid
  Staging: et131x: unify return value of .ndo_set_mac_address if
    address is invalid
  br_device: unify return value of .ndo_set_mac_address if address is
    invalid

 drivers/net/ethernet/aeroflex/greth.c              |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sun/niu.c                     |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    2 +-
 drivers/net/ethernet/tile/tilepro.c                |    2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    2 +-
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/staging/et131x/et131x.c                    |    2 +-
 net/bridge/br_device.c                             |    2 +-
 21 files changed, 21 insertions(+), 21 deletions(-)

-- 
1.7.8.3
