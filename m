From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 0/4] Stacked vlan TSO for virtual devices
Date: Fri, 31 Jul 2015 15:03:23 +0900
Message-ID: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

Basically virtual devices do not need to segment double tagged packets.
This patch set adds TSO feature for double tagged packets to several
virtual devices, which can be realized by simply setting
.ndo_features_check to passthru_features_check.

Toshiaki Makita (4):
  macvlan: Don't segment multiple tagged packets on macvlan device
  veth: Don't segment multiple tagged packets on veth device
  bridge: Don't segment multiple tagged packets on bridge device
  tuntap: Don't segment multiple tagged packets on tap device

 drivers/net/macvlan.c  | 1 +
 drivers/net/tun.c      | 1 +
 drivers/net/veth.c     | 1 +
 net/bridge/br_device.c | 1 +
 4 files changed, 4 insertions(+)

-- 
1.8.1.2
