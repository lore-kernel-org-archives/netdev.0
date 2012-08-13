From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next 0/4] packet: Sock-diag extension for packet sockets
 (beginning)
Date: Mon, 13 Aug 2012 19:47:40 +0400
Message-ID: <5029219C.20305@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11820 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444Ab2HMPru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:47:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a set of stuff residing on a AF_PACKET socket which is currently
write-only -- rings, copy_thresh and mclist. But we need to know these
while doing the checkpoint-restore.

As a solution for the similar problem with unix sockets, the sock-diag
engine was developed, so here's the basic implementation of the packet
sockets extension. It doesn't report rings, fanout and stats, but it can
be easily added later.

I'd like to mention, that it's not a strict requirement, that the diag is
used for getting info about sockets, it would be perfectly fine just to
fix the packet getsockopt callback to return the desired info. So, if the
diag for packet sockets is for any reason unacceptable, just let me know.

Thanks,
Pavel
