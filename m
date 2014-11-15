From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net] Open vSwitch
Date: Fri, 14 Nov 2014 17:37:24 -0800
Message-ID: <1416015444-1519-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:38998 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754848AbaKOBh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:37:28 -0500
Received: by mail-pd0-f178.google.com with SMTP id y13so2579370pdi.23
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:37:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following fixes are accumulated in ovs-repo.
Three of them are related to protocol processing, one is
related to memory leak in case of error and one is to
fix race.
Patch "Validate IPv6 flow key and mask values" has conflicts
with net-next, Let me know if you want me to send the patch
for net-next.

----------------------------------------------------------------
The following changes since commit b23dc5a7cc6ebc9a0d57351da7a0e8454c9ffea3:

  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost (2014-11-13 18:07:52 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_ovs

for you to fetch changes up to fecaef85f7188ad1822210e2c7a7625c9a32a8e4:

  openvswitch: Validate IPv6 flow key and mask values. (2014-11-14 15:13:26 -0800)

----------------------------------------------------------------
Daniele Di Proietto (1):
      openvswitch: Fix NDP flow mask validation

Jarno Rajahalme (1):
      openvswitch: Validate IPv6 flow key and mask values.

Jesse Gross (1):
      openvswitch: Fix checksum calculation when modifying ICMPv6 packets.

Pravin B Shelar (2):
      openvswitch: Fix memory leak.
      openvswitch: Convert dp rcu read operation to locked operations

 net/openvswitch/actions.c      | 10 ++++++----
 net/openvswitch/datapath.c     | 14 +++++++-------
 net/openvswitch/flow_netlink.c |  9 ++++++++-
 3 files changed, 21 insertions(+), 12 deletions(-)
