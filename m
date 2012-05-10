From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/3] tcp: Validate recv queue on repair and related stuff
Date: Thu, 10 May 2012 15:49:13 +0400
Message-ID: <4FABAB39.6090201@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:6512 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759246Ab2EJLtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 07:49:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted by Eric, no checks are performed when repairing data in tcp
read queue. He also suggested that the tcp_try_rmem_schedule() gets
out-lined for this.

This set does both of the above, more details are in patch comments.

Applies to net-next.

Thanks,
Pavel
