From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] csum_partial doesn't need cast
Date: Mon, 17 Nov 2008 09:55:10 -0800
Message-ID: <1226944512-13310-1-git-send-email-joe@perches.com>
Cc: David Miller <davem@davemloft.net>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3347 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbYKQRzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 12:55:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first argument to csum_partial is const void *
casts to char/u8 * are not necessary

 drivers/s390/net/qeth_core_offl.c |    8 ++++----
 include/net/checksum.h            |    2 +-
 include/net/ip_vs.h               |    6 +++---
 net/core/netpoll.c                |    2 +-
 net/ipv4/inet_lro.c               |    4 ++--
 net/ipv4/tcp_ipv4.c               |    4 ++--
 net/ipv6/icmp.c                   |    4 ++--
 net/ipv6/mcast.c                  |    2 +-
 net/ipv6/ndisc.c                  |    4 ++--
 net/ipv6/tcp_ipv6.c               |    6 +++---
 net/unix/af_unix.c                |    4 ++--
 11 files changed, 23 insertions(+), 23 deletions(-)

Signed-off-by: Joe Perches <joe@perches.com>


