From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net] Open vSwitch
Date: Thu, 14 Mar 2013 17:15:00 -0700
Message-ID: <1363306506-885-1-git-send-email-jesse@nicira.com>
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

A few different bug fixes, including several for issues with userspace
communication that have gone unnoticed up until now.  These are intended
for net/3.9.

The following changes since commit 19f949f52599ba7c3f67a5897ac6be14bfcb1200:

  Linux 3.8 (2013-02-18 15:58:34 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to d176ca2a48ff2b5d7becfacdcbd1d72c73bd22d1:

  openvswitch: remove some useless comments (2013-02-22 17:02:49 -0800)

----------------------------------------------------------------
Cong Wang (2):
      openvswitch: fix the calculation of checksum for vlan header
      openvswitch: remove some useless comments

Rich Lane (4):
      openvswitch: Fix ovs_vport_cmd_del return value on success
      openvswitch: Fix ovs_vport_cmd_new return value on success
      openvswitch: Call genlmsg_end in queue_userspace_packet
      openvswitch: Fix parsing invalid LLC/SNAP ethertypes

 net/openvswitch/actions.c      |    4 ++--
 net/openvswitch/datapath.c     |    3 +++
 net/openvswitch/flow.c         |    6 +++++-
 net/openvswitch/vport-netdev.c |    3 +--
 net/openvswitch/vport.c        |    3 +--
 5 files changed, 12 insertions(+), 7 deletions(-)
