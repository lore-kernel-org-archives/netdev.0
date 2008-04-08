From: "Denis V. Lunev" <den@openvz.org>
Subject: [TCP 0/6 net-2.6.26]: tcp_proc_register simplification.
Date: Tue, 08 Apr 2008 17:28:38 +0400
Message-ID: <1207661318.7171.22.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5239 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872AbYDHN2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:28:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have found that tcp_proc_register looks in the same way as
udp_proc_register. So, I have ported improvements made in the commits
6f191efe48af62dd5f8917dd21d187f896cd6c81..4ad96d39a2d74c1b2e400b602da2594f5098fc26
to TCP.

Signed-off-by: Denis V. Lunev <den@openvz.org>

