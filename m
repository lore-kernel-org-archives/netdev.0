From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 0/4] Fix for TCP PMTU
Date: Tue, 10 Mar 2015 17:16:22 +0800
Message-ID: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22781 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbbCJJVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 05:21:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset performs some minor fixes for TCP PMTU,
including correct length condition checking when building
probe segment, then checking if there is enough data avaiable
with probe_size, and finally a cosmetics patch to rename
tcp_mtu_probing with tcp_blackhole_probe for clarity.
In addition, clamp sysctl_tcp_probe_threshold.

Fan Du (4):
  ipv4: Rename tcp_mtu_probing to tcp_blackhole_probe
  ipv4: Correct two conditions checking when buildig nskb
  ipv4: Use probe_size to check write queue data length
  ipv4: clamp sysctl_tcp_probe_threshold

 net/ipv4/tcp_output.c |   14 ++++++--------
 net/ipv4/tcp_timer.c  |    5 +++--
 2 files changed, 9 insertions(+), 10 deletions(-)
