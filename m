From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 00/20] bridge: complete netlink support
Date: Sun,  4 Oct 2015 14:23:27 +0200
Message-ID: <1443961427-15085-1-git-send-email-razor@blackwall.org>
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
This set completes the bridge device's netlink support and makes it
possible to view and configure everything that can be configured via
sysfs. I have tested all of these (setting and getting). There're a few
longer line warnings about the br_get_size() ifla comments but I think we
should have them to know what has been accounted for. I have used the sysfs
interface as a guide of what and how to set. As usual I'll send the
corresponding iproute2 patches later.
The bridge port's netlink interface will be completed after this set gets
applied in some form.

This patch-set is on top of my last vlan cleanups set:
http://www.spinics.net/lists/netdev/msg346005.html

Cheers,
 Nik

Nikolay Aleksandrov (20):
  bridge: netlink: add group_fwd_mask support
  bridge: netlink: export root id
  bridge: netlink: export bridge id
  bridge: netlink: export root port
  bridge: netlink: export root path cost
  bridge: netlink: export topology_change and topology_change_detected
  bridge: netlink: export all timers
  bridge: netlink: add group_addr support
  bridge: netlink: add fdb flush
  bridge: netlink: add support for multicast_router
  bridge: netlink: add support for multicast_snooping
  bridge: netlink: add support for multicast_query_use_ifaddr
  bridge: netlink: add support for multicast_querier
  bridge: netlink: add support for igmp's hash_elasticity
  bridge: netlink: add support for igmp's hash_max
  bridge: netlink: add support for multicast_last_member_count
  bridge: netlink: add support for multicast_startup_query_count
  bridge: netlink: add support for igmp's intervals
  bridge: netlink: add support for netfilter tables config
  bridge: netlink: add support for default_pvid

 include/uapi/linux/if_link.h |  36 ++++++
 net/bridge/br_netlink.c      | 284 ++++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_private.h      |   1 +
 net/bridge/br_vlan.c         |  14 +--
 4 files changed, 326 insertions(+), 9 deletions(-)

-- 
2.4.3
