From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] epoll: add EPOLLEXCLUSIVE support
Date: Tue, 14 Feb 2012 16:23:49 -0500 (EST)
Message-ID: <20120214.162349.569596872424068284.davem@davemloft.net>
References: <1329252484-6309-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, eric.dumazet@gmail.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364Ab2BNVX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 16:23:56 -0500
In-Reply-To: <1329252484-6309-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Tue, 14 Feb 2012 21:48:04 +0100

> High performance server sometimes create one listening socket (e.g. port
> 80), create a epoll file descriptor and add the socket. Afterwards
> create SC_NPROCESSORS_ONLN threads and wait for events. This often
> result in a thundering herd problem because all CPUs are scheduled.
> 
> This patch add an additional flag to epoll_ctl(2) called EPOLLEXCLUSIVE.
> If a descriptor is added with this flag only one CPU is scheduled in.
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Reported-by: Li Yu <raise.sail@gmail.com>

This is not a networking specific change and therefore should not
be submitted via my tree(s).
