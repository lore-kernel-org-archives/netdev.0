From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Tue, 07 Jan 2014 18:14:38 -0500 (EST)
Message-ID: <20140107.181438.1024597653926345336.davem@davemloft.net>
References: <1389118999-16359-1-git-send-email-hkchu@google.com>
	<20140107.162251.778631453084913688.davem@davemloft.net>
	<CAPshTCj+jXjvKCRdBPZYdxPQzTXqKUdF7x2DJE-fBjECVZfH6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbaAGXOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:14:42 -0500
In-Reply-To: <CAPshTCj+jXjvKCRdBPZYdxPQzTXqKUdF7x2DJE-fBjECVZfH6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Tue, 7 Jan 2014 14:55:34 -0800

> I hope I've understood this correctly but with Eric's recent patch
> "gre_offload: statically build GRE offloading support", gre_offload.o
> is always present in the kernel regardless of the GRE configuration
> option. And gre_offload.o is all that's needed for GRE-GRO to happen.

I forgot that he changed the registry to happen directly via
module_init(), you're right.  Ignore me :-)
