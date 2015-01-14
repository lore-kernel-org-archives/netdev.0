From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: DSA fixes for bridge and
	ip-autoconf
Date: Wed, 14 Jan 2015 09:52:10 -0800
Message-ID: <1421257932-11073-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, bridge@lists.linux-foundation.org,
	kaber@trash.net, davem@davemloft.net, buytenh@wantstofly.org
To: netdev@vger.kernel.org
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

Hi David,

These two patches address some real world use cases of the DSA master and slave
network devices.

You have already seen patch 1 previously and you rejected it since my
explanations were not good enough to provide a justification as to why it is
useful, hopefully this time my explanation is better.

Patch 2 solves a different, yet very real problem as well at the bridge layer
when using DSA network devices.

Thanks!

Florian Fainelli (2):
  net: ipv4: handle DSA enabled master network devices
  net: bridge: reject DSA-enabled master netdevices as bridge members

 net/bridge/br_if.c  | 10 ++++++++--
 net/ipv4/ipconfig.c | 10 +++++++---
 2 files changed, 15 insertions(+), 5 deletions(-)

-- 
2.1.0
