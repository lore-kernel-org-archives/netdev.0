From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/17] Finish IPv4 infrastructure namespacing
Date: Wed, 06 Feb 2008 13:53:10 +0300
Message-ID: <47A99196.2030105@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53944 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756910AbYBFKw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 05:52:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set finally allows to manipulate with network devices inside a
namespace and allows to configure them [via netlink]. 'route' is not yet
supported (but prepared to).

Additionally, better routing cache support is added.

By the way, working ICMP is behind a couple of patches after this set :)

Signed-off-by: Denis V. Lunev <den@openvz.org>

