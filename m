From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT PULL net-next] Open vSwitch
Date: Fri, 18 Nov 2011 15:12:14 -0800
Message-ID: <1321657938-21761-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This series of patches proposes the Open vSwitch kernel components for
upstream.  Open vSwitch has existed as a separate project for several
years and we now believe it to be mature enough for inclusion.  The
actual functionality is described more fully in the commit that adds
the kernel code.

The following changes since commit f8a15af093b19b86d56933c8757cee298d0f32a8:

  team: replace kmalloc+memcpy by kmemdup (2011-11-18 14:55:03 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git for-upstream

Jesse Gross (1):
      net: Add Open vSwitch kernel components.

Pravin B Shelar (3):
      genetlink: Add genl_notify()
      genetlink: Add lockdep_genl_is_held().
      vlan: Move vlan_set_encap_proto() to vlan header file

 Documentation/networking/00-INDEX        |    2 +
 Documentation/networking/openvswitch.txt |  195 +++
 MAINTAINERS                              |    8 +
 include/linux/genetlink.h                |    3 +
 include/linux/if_vlan.h                  |   34 +
 include/linux/openvswitch.h              |  452 +++++++
 include/net/genetlink.h                  |    2 +
 net/8021q/vlan_core.c                    |   33 -
 net/Kconfig                              |    1 +
 net/Makefile                             |    1 +
 net/netlink/genetlink.c                  |   21 +
 net/openvswitch/Kconfig                  |   28 +
 net/openvswitch/Makefile                 |   14 +
 net/openvswitch/actions.c                |  415 +++++++
 net/openvswitch/datapath.c               | 1888 ++++++++++++++++++++++++++++++
 net/openvswitch/datapath.h               |  125 ++
 net/openvswitch/dp_notify.c              |   70 ++
 net/openvswitch/flow.c                   | 1373 ++++++++++++++++++++++
 net/openvswitch/flow.h                   |  195 +++
 net/openvswitch/vport-internal_dev.c     |  241 ++++
 net/openvswitch/vport-internal_dev.h     |   28 +
 net/openvswitch/vport-netdev.c           |  200 ++++
 net/openvswitch/vport-netdev.h           |   42 +
 net/openvswitch/vport.c                  |  396 +++++++
 net/openvswitch/vport.h                  |  205 ++++
 25 files changed, 5939 insertions(+), 33 deletions(-)
 create mode 100644 Documentation/networking/openvswitch.txt
 create mode 100644 include/linux/openvswitch.h
 create mode 100644 net/openvswitch/Kconfig
 create mode 100644 net/openvswitch/Makefile
 create mode 100644 net/openvswitch/actions.c
 create mode 100644 net/openvswitch/datapath.c
 create mode 100644 net/openvswitch/datapath.h
 create mode 100644 net/openvswitch/dp_notify.c
 create mode 100644 net/openvswitch/flow.c
 create mode 100644 net/openvswitch/flow.h
 create mode 100644 net/openvswitch/vport-internal_dev.c
 create mode 100644 net/openvswitch/vport-internal_dev.h
 create mode 100644 net/openvswitch/vport-netdev.c
 create mode 100644 net/openvswitch/vport-netdev.h
 create mode 100644 net/openvswitch/vport.c
 create mode 100644 net/openvswitch/vport.h
