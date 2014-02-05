From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net] Open vSwitch
Date: Tue,  4 Feb 2014 22:59:16 -0800
Message-ID: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:41889 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932211AbaBEG7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 01:59:33 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so9213819pde.21
        for <netdev@vger.kernel.org>; Tue, 04 Feb 2014 22:59:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A handful of bug fixes for net/3.14. High level fixes are:
 * Regressions introduced by the zerocopy changes, particularly with
   old userspaces.
 * A few bugs lingering from the introduction of megaflows.
 * Overly zealous error checking that is now being triggered frequently
   in common cases.

The following changes since commit bce3ea81d5b2a33ed0e275d58a45f10ce95cbd50:

  xen-netfront: handle backend CLOSED without CLOSING (2014-02-04 20:42:36 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to c14e0953ca51dbcb8d1ac92acbdcff23d0caa158:

  openvswitch: Suppress error messages on megaflow updates (2014-02-04 22:32:38 -0800)

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

 net/openvswitch/datapath.c   | 23 ++++++++----
 net/openvswitch/flow_table.c | 88 ++++++++++++++++++++++----------------------
 net/openvswitch/flow_table.h |  2 +-
 3 files changed, 60 insertions(+), 53 deletions(-)
