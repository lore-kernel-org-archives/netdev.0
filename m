From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/6 net-2.6.25] Provide correct namespace on IPv4 packet input
 path.
Date: Mon, 21 Jan 2008 17:49:50 +0300
Message-ID: <4794B10E.7010703@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, devel@openvz.org,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:57735 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751216AbYAUOtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 09:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset sequentially adds namespace parameter to fib_lookup and
inetdev_by_index. After that it is possible to pass network namespace
from input packet to routing engine.

Output path is much more intrusive and will be sent separately.

Signed-off-by: Denis V. Lunev <den@openvz.org>
