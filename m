From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: md5: release request socket instead of
 listener
Date: Tue, 16 Feb 2016 20:26:45 -0500 (EST)
Message-ID: <20160216.202645.701144805274843634.davem@davemloft.net>
References: <1455259829-17501-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933123AbcBQB0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:26:48 -0500
In-Reply-To: <1455259829-17501-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu, 11 Feb 2016 22:50:29 -0800

> If tcp_v4_inbound_md5_hash() returns an error, we must release
> the refcount on the request socket, not on the listener.
> 
> The bug was added for IPv4 only.
> 
> Fixes: 079096f103fac ("tcp/dccp: install syn_recv requests into ehash table")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
