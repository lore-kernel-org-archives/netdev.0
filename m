From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv4 net-next 0/2] Add two new flags to bridge.
Date: Wed,  5 Jun 2013 10:07:59 -0400
Message-ID: <1370441281-11281-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
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

The following series adds 2 new flags to bridge.  One flag allows
the user to control whether mac learning is performed on the interface
or not.  By default mac learning is on.
The other flag allows the user to control whether unicast traffic
is flooded (send without an fdb) to a given unicast port.  Default is
on.

Changes since v4:
 - Implemented Stephen's suggestions.

Changes since v2:
 - removed unused "unlock" tag.

Changes since v1:
 - Integrated suggestion from MST to not impact RTM_NEWNEIGH and to
   skip lookups when learning is disabled.

Vlad Yasevich (2):
  bridge: Add flag to control mac learning.
  bridge: Add a flag to control unicast packet flood.

Vlad Yasevich (2):
  bridge: Add flag to control mac learning.
  bridge: Add a flag to control unicast packet flood.

 include/uapi/linux/if_link.h |    2 ++
 net/bridge/br_device.c       |    8 ++++----
 net/bridge/br_forward.c      |   14 +++++++++-----
 net/bridge/br_if.c           |    2 +-
 net/bridge/br_input.c        |   15 ++++++++++-----
 net/bridge/br_netlink.c      |   10 +++++++++-
 net/bridge/br_private.h      |    7 +++++--
 net/bridge/br_sysfs_if.c     |    4 ++++
 8 files changed, 44 insertions(+), 18 deletions(-)

-- 
1.7.7.6
