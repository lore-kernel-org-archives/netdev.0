From: David Miller <davem@davemloft.net>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Sun, 16 May 2010 00:35:24 -0700 (PDT)
Message-ID: <20100516.003524.148541247.davem@davemloft.net>
References: <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	<1273210774.2222.45.camel@edumazet-laptop>
	<1273219222.2261.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhaskie@gmail.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753501Ab0EPHfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 03:35:16 -0400
In-Reply-To: <1273219222.2261.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 May 2010 10:00:22 +0200

> [PATCH] tcp: fix MD5 (RFC2385) support
> 
> TCP MD5 support uses percpu data for temporary storage. It currently
> disables preemption so that same storage cannot be reclaimed by another
> thread on same cpu.
> 
> We also have to make sure a softirq handler wont try to use also same
> context. Various bug reports demonstrated corruptions.
> 
> Fix is to disable preemption and BH.
> 
> Reported-by: Bhaskar Dutta <bhaskie@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
