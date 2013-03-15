From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [GIT net-next] Open vSwitch
Date: Fri, 15 Mar 2013 10:38:46 -0700
Message-ID: <1363369131-16830-1-git-send-email-jesse@nicira.com>
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

A couple of minor enhancements for net-next/3.10.  The largest is an
extension to allow variable length metadata to be passed to userspace
with packets.

There is a merge conflict in net/openvswitch/vport-internal_dev.c:
A existing commit modifies internal_dev_mac_addr() and a new commit
deletes it.  The new one is correct, so you can just remove that function.

The following changes since commit a5a81f0b9025867efb999d14a8dfc1907c5a4c3b:

  ipv6: Fix default route failover when CONFIG_IPV6_ROUTER_PREF=n (2012-12-03 15:34:47 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 4490108b4a5ada14c7be712260829faecc814ae5:

  openvswitch: Allow OVS_USERSPACE_ATTR_USERDATA to be variable length. (2013-02-22 16:29:22 -0800)

----------------------------------------------------------------
Ben Pfaff (1):
      openvswitch: Allow OVS_USERSPACE_ATTR_USERDATA to be variable length.

Jarno Rajahalme (2):
      linux/openvswitch.h: Make OVSP_LOCAL 32-bit.
      openvswitch: Change ENOENT return value to ENODEV in lookup_vport().

Thomas Graf (2):
      openvswitch: Use eth_mac_addr() instead of duplicating it
      openvswitch: Avoid useless holes in struct vport

 include/linux/openvswitch.h          |   13 +++++++------
 net/openvswitch/datapath.c           |   13 +++++++------
 net/openvswitch/datapath.h           |    2 +-
 net/openvswitch/vport-internal_dev.c |   14 ++------------
 net/openvswitch/vport.h              |    4 ++--
 5 files changed, 19 insertions(+), 27 deletions(-)
