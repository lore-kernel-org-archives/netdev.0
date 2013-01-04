From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v3 0/3] netpoll: add IPv6 support
Date: Fri,  4 Jan 2013 11:14:30 +0800
Message-ID: <1357269273-7575-1-git-send-email-amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643Ab3ADDOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2013 22:14:52 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r043EqVe022331
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 3 Jan 2013 22:14:52 -0500
Received: from cr0.redhat.com (vpn-245-104.nrt.redhat.com [10.64.245.104])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r043EiGw001432
	for <netdev@vger.kernel.org>; Thu, 3 Jan 2013 22:14:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resend with a cover letter)

v3: fix CONFIG_IPV6=m case

v2: use bool for ipv6 flag
    fix !CONFIG_IPV6 case

This patchset implements netpoll over IPv6.

Cong Wang (3)
    netconsole: add IPv6 example in doc
    netpoll: add IPv6 support
    netpoll: prepare for ipv6

 Documentation/networking/netconsole.txt |    7 +-
 drivers/net/Kconfig                     |    5 +
 drivers/net/netconsole.c                |   44 ++-
 include/linux/netpoll.h                 |   13 +-
 include/net/udp.h                       |    2 +
 net/core/netpoll.c                      |  629 ++++++++++++++++++++++---------
 net/ipv6/udp.c                          |    3 +-
 7 files changed, 518 insertions(+), 185 deletions(-)
