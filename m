From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] NET : secure sequence number functions can use nsec resolution instead of usec
Date: Wed, 28 Mar 2007 18:41:32 +0200
Message-ID: <20070328164132.GA8863@one.firstfloor.org>
References: <20070328174322.5d806dd0.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40273 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbXC1Qlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 12:41:35 -0400
Content-Disposition: inline
In-Reply-To: <20070328174322.5d806dd0.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 05:43:22PM +0200, Eric Dumazet wrote:
> Hello David
> 
> We could use the nanosec resolution for various functions defined in drivers/char/random.c
> (secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number())
> 
> I am not sure if it's a netdev related patch or core kernel, so I have CC Andrew.
> 
> Thank you
> 
> [PATCH] NET : random functions can use nsec resolution instead of usec
> 
> In order to get more randomness for secure_tcpv6_sequence_number(), secure_tcp_sequence_number(), secure_dccp_sequence_number() functions, we can use the high resolution time services, providing nanosec resolution.

It's also a little faster because it avoids one division.

You didn't mention the initial seed change.
There you could have removed the useless utsname initialization too.


> 
> I've also done two kmalloc()/kzalloc() conversions.


Normally that should be separate patches

-Andi
