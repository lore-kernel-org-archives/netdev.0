From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Fri, 14 Jun 2013 15:28:49 -0700
Message-ID: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
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

A few miscellaneous improvements and cleanups before the GRE tunnel
integration series. Intended for net-next/3.11.

The following changes since commit f722406faae2d073cc1d01063d1123c35425939e:

  Linux 3.10-rc1 (2013-05-11 17:14:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 93d8fd1514b6862c3370ea92be3f3b4216e0bf8f:

  openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs() (2013-06-14 15:09:12 -0700)

----------------------------------------------------------------
Andy Hill (1):
      openvswitch: Fix misspellings in comments and docs.

Jesse Gross (2):
      openvswitch: Immediately exit on error in ovs_vport_cmd_set().
      openvswitch: Remove unused get_config vport op.

Lorand Jakab (1):
      openvswitch: fix variable names in comment

Pravin B Shelar (4):
      openvswitch: Unify vport error stats handling.
      openvswitch: Fix struct comment.
      openvswitch: make skb->csum consistent with rest of networking stack.
      openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs()

 include/uapi/linux/openvswitch.h     |  1 -
 net/openvswitch/actions.c            |  4 ++++
 net/openvswitch/datapath.c           | 17 ++++++++---------
 net/openvswitch/flow.c               | 29 +++++++++++++++--------------
 net/openvswitch/flow.h               |  4 ++--
 net/openvswitch/vport-internal_dev.c |  1 +
 net/openvswitch/vport-netdev.c       |  7 ++++---
 net/openvswitch/vport-netdev.h       |  1 -
 net/openvswitch/vport.c              | 11 ++++++++---
 net/openvswitch/vport.h              | 13 +++++++++----
 10 files changed, 51 insertions(+), 37 deletions(-)
