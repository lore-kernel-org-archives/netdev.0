From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/11 net-2.6.26] UDP/ICMP/TCP for a namespace
Date: Mon, 24 Mar 2008 17:33:05 +0300
Message-ID: <1206369185.23705.7.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	containers <containers@lists.osdl.org>, xemul <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24887 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758556AbYCXOdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 10:33:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dave!

This patch set finally enables TCP/UDP and ICMP inside a namespace.
In order to do this we fix ARP processing, IP options processing and
allow packets to flow to namespace aware protocols.

Finally, this makes namespace functional and alive :)

Signed-off-by: Denis V. Lunev <den@openvz.org>

