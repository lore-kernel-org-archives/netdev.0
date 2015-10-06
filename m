From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/8] bridge: netlink: complete port
	attribute support
Date: Tue,  6 Oct 2015 14:11:54 +0200
Message-ID: <1444133522-16907-1-git-send-email-razor@blackwall.org>
Cc: bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com, davem@davemloft.net
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This is the second set that completes the bridge port's netlink support and
makes everything from sysfs available via netlink. I've used sysfs as a
guide of what and how to set again. I've tested setting/getting every
option and also this time tested enabling KASAN. Again there're a few long
line warnings about the ifla attribute names in br_port_info_size() but
as the previous set - it's good to know what's been accounted for.

Cheers,
 Nik

Nikolay Aleksandrov (8):
  bridge: netlink: export port's root id
  bridge: netlink: export port's bridge id
  bridge: netlink: export port's designated cost and port
  bridge: netlink: export port's id and number
  bridge: netlink: export port's topology_change_ack and config_pending
  bridge: netlink: export port's timer values
  bridge: netlink: allow to flush port's fdb
  bridge: netlink: add support for port's multicast_router attribute

 include/uapi/linux/if_link.h | 13 ++++++++++
 net/bridge/br_netlink.c      | 57 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 69 insertions(+), 1 deletion(-)

-- 
2.4.3
