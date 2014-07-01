From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net] Open vSwitch
Date: Mon, 30 Jun 2014 23:33:16 -0700
Message-ID: <1404196396-5040-1-git-send-email-pshelar@nicira.com>
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

A set of fixes for net.
First bug is related flow-table management.  Second one is in sample
action. Third is related flow stats and last one add gre-err handler for ovs.

The following changes since commit dba63115ce0c888fcb4cdec3f8a4ba97d144afaf:

  powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT test (2014-06-27 16:14:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_ovs_fixes

for you to fetch changes up to 4a46b24e147dfa9b858026da02cad0bdd4e149d2:

  openvswitch: Use exact lookup for flow_get and flow_del. (2014-06-30 20:47:15 -0700)

----------------------------------------------------------------
Alex Wang (1):
      openvswitch: Use exact lookup for flow_get and flow_del.

Andy Zhou (1):
      openvswitch: Fix a double free bug for the sample action

Ben Pfaff (1):
      openvswitch: Fix tracking of flags seen in TCP flows.

Wei Zhang (1):
      openvswitch: supply a dummy err_handler of gre_cisco_protocol to prevent kernel crash

 net/openvswitch/actions.c    |  2 ++
 net/openvswitch/datapath.c   | 27 +++++++++++++--------------
 net/openvswitch/flow.c       |  4 ++--
 net/openvswitch/flow.h       |  5 +++--
 net/openvswitch/flow_table.c | 16 ++++++++++++++++
 net/openvswitch/flow_table.h |  3 ++-
 net/openvswitch/vport-gre.c  | 17 +++++++++++++++++
 7 files changed, 55 insertions(+), 19 deletions(-)
