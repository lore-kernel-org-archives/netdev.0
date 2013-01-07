From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v4 0/3] netpoll: add IPv6 support
Date: Mon,  7 Jan 2013 15:17:13 +0800
Message-ID: <1357543036-15492-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28134 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441Ab3AGHR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 02:17:28 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r077HShd026346
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2013 02:17:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4: remove ndisc_parse_options(), ignore ICMP options there
    make udp6_csum_init() inline so that we don't rely on IPV6=y
    fix a conflict with Jiri's patchset

v3: fix CONFIG_IPV6=m case
 
v2: use bool for ipv6 flag
    fix !CONFIG_IPV6 case

This patchset implements netpoll over IPv6.

Cong Wang (3):
  netpoll: prepare for ipv6
  netpoll: add IPv6 support
  netconsole: add IPv6 example in doc

 Documentation/networking/netconsole.txt |    7 +-
 drivers/net/netconsole.c                |   46 ++-
 include/linux/netpoll.h                 |   13 +-
 include/net/udp.h                       |   34 ++
 net/core/netpoll.c                      |  617 ++++++++++++++++++++++---------
 net/ipv6/udp.c                          |   34 --
 6 files changed, 534 insertions(+), 217 deletions(-)

-- 
1.7.7.6
