From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 0/2] TProxy IPv6 support, 2nd round, iptables portion
Date: Mon, 21 Sep 2009 17:43:06 +0200
Message-ID: <1253548039.12519.14.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58465 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752464AbZIUQZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 12:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series accompanies the TProxy IPv6 2nd round patches and adds userspace
support for the TPROXY target and the socket match.  

Since the last post, I've fixed the xt_socket.h header file which contained
an obsolete struct declaration for the xt_socket matchinfo, but this is not
incompatible with the previous patch, thus you don't need to recompile
iptables if you already have the old binaries.

Balazs Scheidler (2):
  TProxy: added IPv6 support for socket match
  TProxy: added IPv6 support to the TPROXY target

 extensions/libxt_TPROXY.c           |  213 +++++++++++++++++++++++++++++------
 extensions/libxt_socket.c           |  103 ++++++++++++++++--
 extensions/libxt_socket.man         |    6 +-
 include/linux/netfilter/xt_TPROXY.h |   15 ++-
 include/linux/netfilter/xt_socket.h |   12 ++
 5 files changed, 299 insertions(+), 50 deletions(-)
 create mode 100644 include/linux/netfilter/xt_socket.h

