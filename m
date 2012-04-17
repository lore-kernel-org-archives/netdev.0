From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 0/2] l2tp: Introduce L2TPv3 IP encapsulation for IPv6
Date: Tue, 17 Apr 2012 13:29:24 +0100
Message-ID: <1334665766-11461-1-git-send-email-jchapman@katalix.com>
References: <y>
Cc: bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52700 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932111Ab2DQM3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 08:29:35 -0400
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series adds support for L2TPv3 IP encapsulation
over IPv6. Support for L2TPv3 IP encap over IPv4 is already present in
the kernel (l2tp_ip). The new code is derived from l2tp_ip and
ipv6/raw. I'm posting as an RFC to get feedback on the approach being
used, because the implementation uses several ipv6 functions which are
not currently exported.

A patch series adding IPv6 support for L2TPv2 and L2TPv3 UDP
encapsulation is being worked on by Ben LaHaise and is independent of
these changes.

James Chapman (2):
  ipv6: Export ipv6 functions for use by other protocols
  l2tp: Introduce L2TPv3 IP encapsulation support for IPv6

 include/linux/l2tp.h     |   17 +
 net/ipv6/datagram.c      |    4 +
 net/ipv6/exthdrs.c       |    1 +
 net/ipv6/ip6_flowlabel.c |    1 +
 net/ipv6/ip6_output.c    |    3 +
 net/l2tp/Makefile        |    1 +
 net/l2tp/l2tp_ip6.c      |  808 ++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 835 insertions(+), 0 deletions(-)
 create mode 100644 net/l2tp/l2tp_ip6.c
