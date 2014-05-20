From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Tue, 20 May 2014 01:59:38 -0700
Message-ID: <1400576378-2171-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

A set of OVS changes for net-next/3.16.

Most of change are related to improving performance of flow setup by
minimizing critical sections.

The following changes since commit 091b64868b43ed84334c6623ea6a08497529d4ff:

  Merge branch 'mlx4-next' (2014-05-22 17:17:34 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git master

for you to fetch changes up to 0c200ef94c9492205e18a18c25650cf27939889c:

  openvswitch: Simplify genetlink code. (2014-05-22 16:27:37 -0700)

----------------------------------------------------------------
Jarno Rajahalme (12):
  openvswitch: Compact sw_flow_key.
  openvswitch: Avoid assigning a NULL pointer to flow actions.
  openvswitch: Clarify locking.
  openvswitch: Build flow cmd netlink reply only if needed.
  openvswitch: Make flow mask removal symmetric.
  openvswitch: Minimize dp and vport critical sections.
  openvswitch: Fix typo.
  openvswitch: Fix ovs_flow_stats_get/clear RCU dereference.
  openvswitch: Reduce locking requirements.
  openvswitch: Minimize ovs_flow_cmd_del critical section.
  openvswitch: Split ovs_flow_cmd_new_or_set().
  openvswitch: Minimize ovs_flow_cmd_new|set critical sections.

Pravin B Shelar (1):
  openvswitch: Simplify genetlink code.

 include/uapi/linux/openvswitch.h |   4 +-
 net/openvswitch/datapath.c       | 771 +++++++++++++++++++++++----------------
 net/openvswitch/flow.c           |  53 ++-
 net/openvswitch/flow.h           |  35 +-
 net/openvswitch/flow_netlink.c   | 112 ++----
 net/openvswitch/flow_table.c     |  46 ++-
 6 files changed, 558 insertions(+), 463 deletions(-)

-- 
1.9.0
