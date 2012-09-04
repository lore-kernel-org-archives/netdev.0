From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Tue,  4 Sep 2012 12:14:07 -0700
Message-ID: <1346786049-3100-1-git-send-email-jesse@nicira.com>
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

Two feature additions to Open vSwitch for net-next/3.7.

The following changes since commit 0d7614f09c1ebdbaa1599a5aba7593f147bf96ee:

  Linux 3.6-rc1 (2012-08-02 16:38:10 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 15eac2a74277bc7de68a7c2a64a7c91b4b6f5961:

  openvswitch: Increase maximum number of datapath ports. (2012-09-03 19:20:49 -0700)

----------------------------------------------------------------
Pravin B Shelar (2):
      openvswitch: Add support for network namespaces.
      openvswitch: Increase maximum number of datapath ports.

 net/openvswitch/actions.c            |    2 +-
 net/openvswitch/datapath.c           |  375 +++++++++++++++++++++-------------
 net/openvswitch/datapath.h           |   50 ++++-
 net/openvswitch/dp_notify.c          |    8 +-
 net/openvswitch/flow.c               |   11 +-
 net/openvswitch/flow.h               |    3 +-
 net/openvswitch/vport-internal_dev.c |    7 +-
 net/openvswitch/vport-netdev.c       |    2 +-
 net/openvswitch/vport.c              |   23 ++-
 net/openvswitch/vport.h              |    7 +-
 10 files changed, 317 insertions(+), 171 deletions(-)
