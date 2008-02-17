From: David Miller <davem@davemloft.net>
Subject: Re: include/linux/pcounter.h
Date: Sat, 16 Feb 2008 21:54:01 -0800 (PST)
Message-ID: <20080216.215401.20463603.davem@davemloft.net>
References: <20080216025051.751b4a86.akpm@linux-foundation.org>
	<47B6D12A.3090401@cosmosbay.com>
	<20080216112618.ec450f9b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41486
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751755AbYBQFx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 00:53:27 -0500
In-Reply-To: <20080216112618.ec450f9b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 16 Feb 2008 11:26:18 -0800

> On Sat, 16 Feb 2008 13:03:54 +0100 Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > Yes, per connection basis. Some workloads want to open/close more than 1000 
> > sockets per second.
> 
> ie: slowpath

Definitely not slow path in the networking.

Connection rates are definitely as, or more, important than packet
rates for certain workloads.
