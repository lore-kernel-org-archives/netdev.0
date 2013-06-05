From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: htb: do not mix 1ns and 64ns time units
Date: Tue, 04 Jun 2013 17:44:39 -0700 (PDT)
Message-ID: <20130604.174439.327058035432515764.davem@davemloft.net>
References: <1370361306.24311.214.camel@edumazet-glaptop>
	<1370361727.24311.215.camel@edumazet-glaptop>
	<1370365908.24311.222.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, stephen@networkplumber.org, jbenc@redhat.com,
	j.vimal@gmail.com, soltys@ziu.info, vapier@gentoo.org,
	jussi.kivilinna@mbnet.fi, kaber@trash.net, jpirko@redhat.com,
	toke@toke.dk, dave.taht@gmail.com, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, dan@coverfire.com, jg@freedesktop.org,
	cyrus@openwrt.org, nbd@nbd.name
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab3FEAok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 20:44:40 -0400
In-Reply-To: <1370365908.24311.222.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Jun 2013 10:11:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 56b765b79 ("htb: improved accuracy at high rates") added another
> regression for low rates, because it mixes 1ns and 64ns time units.
> 
> So the maximum delay (mbuffer) was not 60 second, but 937 ms.
> 
> Lets convert all time fields to 1ns as 64bit arches are becoming the
> norm.
> 
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
