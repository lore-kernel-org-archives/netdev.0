From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net] Open vSwitch
Date: Tue, 16 Apr 2013 13:17:27 -0700
Message-ID: <1366143449-8605-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:46102 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934781Ab3DPURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:17:24 -0400
Received: by mail-pa0-f71.google.com with SMTP id fb10so767600pad.6
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 13:17:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two small bug fixes for net/3.9 including the issue previously
discussed where allocation of netlink notifications can fail after
changes have been committed.

The following changes since commit 330305cc4a6b0cb75c22fc01b8826f0ad755550f:

  ipv4: Fix ip-header identification for gso packets. (2013-03-26 13:50:05 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to d3e1101c9b75574e68380b5cb10c9395fd8855de:

  openvswitch: correct an invalid BUG_ON (2013-03-27 09:07:41 -0700)

----------------------------------------------------------------
Hong Zhiguo (1):
      openvswitch: correct an invalid BUG_ON

Jesse Gross (1):
      openvswitch: Preallocate reply skb in ovs_vport_cmd_set().

 net/openvswitch/datapath.c |   30 ++++++++++++++++++------------
 net/openvswitch/flow.c     |    2 +-
 2 files changed, 19 insertions(+), 13 deletions(-)
