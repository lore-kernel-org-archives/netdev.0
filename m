From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet_diag: remove duplicate code from
 inet_twsk_diag_dump()
Date: Thu, 05 Mar 2015 22:55:18 -0500 (EST)
Message-ID: <20150305.225518.263646702699262144.davem@davemloft.net>
References: <1425579494.5130.254.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbbCFDzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:55:20 -0500
In-Reply-To: <1425579494.5130.254.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Mar 2015 10:18:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> timewait sockets now share a common base with established sockets.
> 
> inet_twsk_diag_dump() can use inet_diag_bc_sk() instead of duplicating
> code, granted that inet_diag_bc_sk() does proper userlocks
> initialization.
> 
> twsk_build_assert() will catch any future changes that could break
> the assumptions.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine, thanks Eric.
