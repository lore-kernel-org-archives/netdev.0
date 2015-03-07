From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/6] mpls: Minor fixes and cleanups
Date: Sat, 07 Mar 2015 16:18:58 -0600
Message-ID: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33283 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbbCGWWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:22:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a bunch of small changes that have come out of the discussions
of the mpls code and the automated tests that people run against things.

Eric W. Biederman (6):
      mpls: Fix the kzalloc argument order in mpls_rt_alloc
      mpls: Cleanup the rcu usage in the code.
      mpls: Better error message for unsupported option.
      mpls: Correct the ttl decrement.
      mpls: Fix the openvswitch select of NET_MPLS_GSO
      neigh: Use neigh table index for neigh_packet_xmit

 include/net/neighbour.h |   1 +
 net/core/neighbour.c    |  22 +++++-----
 net/mpls/af_mpls.c      | 114 ++++++++++++++++++++++++++++++------------------
 net/openvswitch/Kconfig |   1 +
 4 files changed, 85 insertions(+), 53 deletions(-)
