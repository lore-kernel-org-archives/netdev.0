From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 0/2] Add some new flags to bridges.
Date: Mon, 29 Apr 2013 11:58:20 -0400
Message-ID: <1367251102-25193-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, bridge@lists.linux-foundation.org,
	mst@redhat.com
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

The follows series adds 2 new flags to bridge.  One flag allows
the user to control whether mac learning is performed on the interface
or not.  By default mac learning is on.
The other flag allows the user to control whether unicast traffic
is flooded (send without an fdb) to a given unicast port.  Default is
on.

Vlad Yasevich (2):
  bridge: Add flag to control mac learning.
  bridge: Add a flag to control unicast packet flood.

 include/uapi/linux/if_link.h |    2 ++
 net/bridge/br_device.c       |    8 ++++----
 net/bridge/br_fdb.c          |    4 ++++
 net/bridge/br_forward.c      |   14 +++++++++-----
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_input.c        |    9 ++++++---
 net/bridge/br_netlink.c      |   10 +++++++++-
 net/bridge/br_private.h      |    7 +++++--
 net/bridge/br_sysfs_if.c     |    4 ++++
 9 files changed, 44 insertions(+), 16 deletions(-)

-- 
1.7.7.6
