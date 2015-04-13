From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not cache align timewait sockets
Date: Sun, 12 Apr 2015 21:17:08 -0400 (EDT)
Message-ID: <20150412.211708.1005488304036582767.davem@davemloft.net>
References: <1428671238.25985.306.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbbDMBRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:17:09 -0400
In-Reply-To: <1428671238.25985.306.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Apr 2015 06:07:18 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> With recent adoption of skc_cookie in struct sock_common,
> struct tcp_timewait_sock size increased from 192 to 200 bytes
> on 64bit arches. SLAB rounds then to 256 bytes.
> 
> It is time to drop SLAB_HWCACHE_ALIGN constraint for twsk_slab.
> 
> This saves about 12 MB of memory on typical configuration reaching
> 262144 timewait sockets, and has no noticeable impact on performance.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks reasonable, applied, thanks.
