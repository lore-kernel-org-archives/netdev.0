From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/17] Finish IPv4 infrastructure namespacing.
Date: Tue, 19 Feb 2008 10:28:36 +0300
Message-ID: <1203406116.27296.1.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23168 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419AbYBSH2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:28:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set finally allows to manipulate with network devices inside a
namespace and allows to configure them [via netlink]. 'route' is not yet
supported (but prepared to) as it requires a socket.

Additionally, better routing cache support is added.

Signed-off-by: Denis V. Lunev <den@openvz.org>

