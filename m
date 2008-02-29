From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/12 net-2.6.26] icmp_socket namespacing
Date: Fri, 29 Feb 2008 16:39:20 +0300
Message-ID: <1204292360.10368.11.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38278 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbYB2NjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 08:39:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches is targeted to create separate icmp_socket inside
each namespace. Both IPv4 and IPv6 codepaths are affected.

Though, in order to do this smoothly, a bit of optimisations are
performed. The kernel from now on will use sock rather than socket on
the ICMP send path.

Signed-off-by: Denis V. Lunev <den@openvz.org>

