From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/13 net-2.6.26] UDP/ICMP/TCP for a namespace v2
Date: Mon, 31 Mar 2008 17:16:07 +0400
Message-ID: <1206969367.10660.16.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	containers <containers@lists.osdl.org>, xemul <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44994 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755074AbYCaNQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:16:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dave!

This patch set finally enables TCP/UDP and ICMP inside a namespace.
In order to do this we fix ARP processing, IP options processing and
allow packets to flow to namespace aware protocols.

Finally, this makes namespace functional and alive :)

Changed from v1:
- inet_csk_ctl_sock_create is renamed to inet_ctl_sock_create. Thanks
  to Arnaldo Carvalho de Melo <acme@redhat.com and Vlad Yasevich
  <vladislav.yasevich@hp.com>
- dccp_ctl_make_reset now accept sock rather than socket. Thanks to
  Arnaldo Carvalho de Melo <acme@redhat.com>
- added inet_ctl_sock_destroy

Signed-off-by: Denis V. Lunev <den@openvz.org>

