From: Stephen Hemminger <shemminger@vyatta.com>
Subject: static_branch() for netpoll?
Date: Thu, 26 Apr 2012 16:22:41 -0700
Message-ID: <20120426162241.4cbd2b33@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34189 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab2DZXWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 19:22:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would be good to use static_branch instead of the current logic used
to detect if traffic trapping is need for netpoll. Most distro's end up
enabling NETPOLL, yet most users never need it.  Not sure about the locking
requirements since netpoll_rx() runs in both hard and soft irq context.
