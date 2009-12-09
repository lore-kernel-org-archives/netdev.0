From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: Fix a connect() race with timewait sockets
Date: Tue, 08 Dec 2009 20:18:50 -0800 (PST)
Message-ID: <20091208.201850.06581533.davem@davemloft.net>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
	<4B152F97.1090409@gmail.com>
	<4B1912CE.5040304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kdakhane@gmail.com, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, zbr@ioremap.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756692AbZLIESn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:18:43 -0500
In-Reply-To: <4B1912CE.5040304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Dec 2009 14:46:54 +0100

> First patch changes __inet_hash_nolisten() and __inet6_hash()
> to get a timewait parameter to be able to unhash it from ehash
> at same time the new socket is inserted in hash.
> 
> This makes sure timewait socket wont be found by a concurrent
> writer in __inet_check_established()
> 
> Reported-by: kapil dakhane <kdakhane@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.
