From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net] Open vSwitch
Date: Sun,  2 Feb 2014 17:08:01 -0800
Message-ID: <1391389686-34303-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org
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

A handful of bug fixes for net/3.14. High level fixes are:
 * Regression introduced by the zerocopy changes, particularly with
   old userspaces.
 * A few bugs lingering from the introduction of megaflows.
 * Overly zealous error checking that is now being triggered frequently
   in common cases.

The following changes since commit 9895c503ef5b32c1ff4c4c224d6e8db2935dc3c0:

  ksz884x: delete useless variable (2014-01-15 13:43:03 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to dd3bceef108f99e21900c872d8b7ec632cfb88ac:

  openvswitch: Suppress error messages on megaflow updates (2014-02-02 16:39:48 -0800)

----------------------------------------------------------------
Andy Zhou (2):
      openvswitch: Fix kernel panic on ovs_flow_free
      openvswitch: Suppress error messages on megaflow updates

Daniele Di Proietto (1):
      openvswitch: Fix ovs_dp_cmd_msg_size()

Pravin B Shelar (1):
      openvswitch: Fix ovs_flow_free() ovs-lock assert.

Thomas Graf (1):
      openvswitch: Pad OVS_PACKET_ATTR_PACKET if linear copy was performed

 net/openvswitch/datapath.c   | 22 +++++++----
 net/openvswitch/flow_table.c | 87 +++++++++++++++++++++-----------------------
 net/openvswitch/flow_table.h |  2 +-
 3 files changed, 57 insertions(+), 54 deletions(-)
