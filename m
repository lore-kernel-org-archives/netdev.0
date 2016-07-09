From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/6] iplink: Improve documentation
Date: Sat,  9 Jul 2016 11:22:44 +0200
Message-ID: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43984 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933103AbcGIJXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series improves documentation around the feature of 'ip link set'
to configure device type specific parameters. While doing so, I reviewed
used fonts in ip-link.8 and fixed a few bugs/inconsistencies.

Phil Sutter (6):
  iplink: List valid 'type' argument in ip link help text
  iplink: bond_slave: Add missing help functions
  ip-link.8: Extend type list in synopsis
  ip-link.8: Place 'ip link set' warning more prominently
  ip-link.8: Add slave type option descriptions
  ip-link.8: Fix font choices

 ip/iplink.c            |   4 +-
 ip/iplink_bond_slave.c |  24 ++++
 man/man8/ip-link.8.in  | 314 +++++++++++++++++++++++++++++++++++--------------
 3 files changed, 254 insertions(+), 88 deletions(-)

-- 
2.8.2
