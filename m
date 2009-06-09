From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: dev_addr_init() fix
Date: Tue, 09 Jun 2009 05:21:50 -0700 (PDT)
Message-ID: <20090609.052150.253563947.davem@davemloft.net>
References: <4A2D006C.70302@cosmosbay.com>
	<20090608130653.GB3272@elte.hu>
	<4A2D16E4.3030702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, vegard.nossum@gmail.com, john.dykstra1@gmail.com,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41150
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758895AbZFIMVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:21:48 -0400
In-Reply-To: <4A2D16E4.3030702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Jun 2009 15:49:24 +0200

> [PATCH net-next-2.6] net: dev_addr_init() fix
> 
> commit f001fde5eadd915f4858d22ed70d7040f48767cf 
> (net: introduce a list of device addresses dev_addr_list (v6))
> added one regression Vegard Nossum found in its testings.
> 
> With kmemcheck help, Vegard found some uninitialized memory
> was read and reported to user, potentialy leaking kernel data.
> ( thread can be found on http://lkml.org/lkml/2009/5/30/177 )
> 
> dev_addr_init() incorrectly uses sizeof() operator. We were
> initializing one byte instead of MAX_ADDR_LEN bytes.
> 
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
