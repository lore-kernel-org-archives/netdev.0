From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/11 net-2.6.16] unify control socket usage for protocols
Date: Fri, 28 Mar 2008 12:04:31 +0300
Message-ID: <1206695071.3271.8.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17783 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbYC1JEH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:04:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dave!

This set provides a unification for control socket usage/creation for
all protocols. The idea is to use sock rather than socket all around the
protocols. (This has been partly done previously for ICMP/IPv6 staff).

Additionally, the creation of such a sockets now performed uniformly via
inet_csk_ctl_sock_create.

After that TCP control socket is created and used on a per/namespace
basis.

Regards,
	Den

P.S. This set includes the patch discussed yesterday with Vlad Yasevich.

