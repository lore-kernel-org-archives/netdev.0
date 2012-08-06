From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/5] Per-net and on-demand link indices (and related)
Date: Mon, 06 Aug 2012 14:30:07 +0400
Message-ID: <501F9CAF.3030605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43188 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab2HFKaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:30:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set tries to summarize the recent discussion of making ifindices friendly
to checkpoint-restore and consists of:

1. Prepare hash function to non-unique ifindices
2. Allow for specifying the desired ifindex on net link creation
3. Make ifindex generation per-net
4. Simplify loopback device ifindex access

Thanks,
Pavel
