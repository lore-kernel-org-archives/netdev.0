From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net] Open vSwitch
Date: Thu, 20 Mar 2014 11:09:10 -0700
Message-ID: <1395338954-26206-1-git-send-email-jesse@nicira.com>
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
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Four small fixes for net/3.14. I realize that these are late in the cycle - just got back from vacation.

The following changes since commit c14e0953ca51dbcb8d1ac92acbdcff23d0caa158:

  openvswitch: Suppress error messages on megaflow updates (2014-02-04 22:32:38 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to f9b8c4c8baded129535d82d74df8e87a7a369f54:

  openvswitch: Correctly report flow used times for first 5 minutes after boot. (2014-03-20 10:45:21 -0700)

----------------------------------------------------------------
Ben Pfaff (1):
      openvswitch: Correctly report flow used times for first 5 minutes after boot.

Jarno Rajahalme (2):
      openvswitch: Read tcp flags only then the tranport header is present.
      openvswitch: Fix race.

Jiri Pirko (1):
      ovs: fix dp check in ovs_dp_reset_user_features

 net/openvswitch/datapath.c | 9 +++++----
 net/openvswitch/flow.c     | 3 ++-
 2 files changed, 7 insertions(+), 5 deletions(-)
