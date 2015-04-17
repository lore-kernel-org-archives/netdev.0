From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: tcp_get_info() should fetch socket fields once
Date: Fri, 17 Apr 2015 13:28:45 -0400 (EDT)
Message-ID: <20150417.132845.1469377605486721196.davem@davemloft.net>
References: <1429225948.7346.232.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbbDQR2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:28:48 -0400
In-Reply-To: <1429225948.7346.232.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Apr 2015 16:12:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_get_info() can be called without holding socket lock,
> so any socket fields can change under us.
> 
> Use READ_ONCE() to fetch sk_pacing_rate and sk_max_pacing_rate
> 
> Fixes: 977cb0ecf82e ("tcp: add pacing_rate information into tcp_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> David, I do not think this needs stable backport, this is a quite
> minor bug. I've added the 'Fixes' tag for reference only.

Ok, applied.
