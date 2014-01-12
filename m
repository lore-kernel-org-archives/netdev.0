From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 0/2] tcp: delete redundant calls of tcp_mtup_init() and
Date: Sun, 12 Jan 2014 15:54:29 +0800
Message-ID: <cover.1389513042.git.panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbaALH5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 02:57:04 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0C7v3na002104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 02:57:04 -0500
Received: from localhost.localdomain.com (dhcp-17-97.nay.redhat.com [10.66.17.97])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s0C7v2Vo005105
	for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 02:57:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that both tcp_v4_syn_recv_sock() and tcp_v6_syn_recv_sock() call them
for new sock, so delete redundant calls of them. 

Weiping Pan (2):
  tcp: delete redundant calls of tcp_mtup_init()
  tcp: delete redundant call of tcp_initialize_rcv_mss()

 net/ipv4/tcp_input.c |    2 --
 net/ipv4/tcp_ipv4.c  |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

-- 
1.7.4
