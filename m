From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net] Open vSwitch
Date: Mon,  7 May 2012 18:51:22 -0700
Message-ID: <1336441885-11085-1-git-send-email-jesse@nicira.com>
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

A few patches for net/3.4.

The following changes since commit dd775ae2549217d3ae09363e3edb305d0fa19928:

  Linux 3.4-rc1 (2012-03-31 16:24:09 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to 072ae6314a191e3a9fc309b1e4e539ac7abc48ad:

  openvswitch: Validation of IPv6 set port action uses IPv4 header (2012-05-07 17:23:10 -0700)

----------------------------------------------------------------
Ansis Atteka (1):
      openvswitch: Release rtnl_lock if ovs_vport_cmd_build_info() failed.

Jesse Gross (1):
      openvswitch: Add length check when retrieving TCP flags.

Pravin B Shelar (1):
      openvswitch: Validation of IPv6 set port action uses IPv4 header

 net/openvswitch/datapath.c |   27 +++++++++++++++++----------
 net/openvswitch/flow.c     |    3 ++-
 2 files changed, 19 insertions(+), 11 deletions(-)
