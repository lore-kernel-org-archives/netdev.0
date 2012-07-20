From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Fri, 20 Jul 2012 15:26:43 -0700
Message-ID: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

A few bug fixes and small enhancements for net-next/3.6.

The following changes since commit bf32fecdc1851ad9ca960f56771b798d17c26cf1:

  openvswitch: Add length check when retrieving TCP flags. (2012-04-02 14:28:57 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to efaac3bf087b1a6cec28f2a041e01c874d65390c:

  openvswitch: Fix typo in documentation. (2012-07-20 14:51:07 -0700)

----------------------------------------------------------------
Ansis Atteka (1):
      openvswitch: Do not send notification if ovs_vport_set_options() failed

Ben Pfaff (1):
      openvswitch: Check gso_type for correct sk_buff in queue_gso_packets().

Jesse Gross (2):
      openvswitch: Enable retrieval of TCP flags from IPv6 traffic.
      openvswitch: Reset upper layer protocol info on internal devices.

Leo Alterman (1):
      openvswitch: Fix typo in documentation.

Pravin B Shelar (1):
      openvswitch: Check currect return value from skb_gso_segment()

Raju Subramanian (1):
      openvswitch: Replace Nicira Networks.

 Documentation/networking/openvswitch.txt |    2 +-
 net/openvswitch/actions.c                |    2 +-
 net/openvswitch/datapath.c               |   13 ++++++++-----
 net/openvswitch/datapath.h               |    2 +-
 net/openvswitch/dp_notify.c              |    2 +-
 net/openvswitch/flow.c                   |    5 +++--
 net/openvswitch/flow.h                   |    2 +-
 net/openvswitch/vport-internal_dev.c     |   10 +++++++++-
 net/openvswitch/vport-internal_dev.h     |    2 +-
 net/openvswitch/vport-netdev.c           |    2 +-
 net/openvswitch/vport-netdev.h           |    2 +-
 net/openvswitch/vport.c                  |    2 +-
 net/openvswitch/vport.h                  |    2 +-
 13 files changed, 30 insertions(+), 18 deletions(-)
