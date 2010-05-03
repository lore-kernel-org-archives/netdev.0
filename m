From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] network driver skb allocations
Date: Mon, 03 May 2010 13:06:55 -0700 (PDT)
Message-ID: <20100503.130655.179288030.davem@davemloft.net>
References: <1272906384.2226.80.camel@edumazet-laptop>
	<1272916166.27948.62.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56691
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756479Ab0ECUGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:06:49 -0400
In-Reply-To: <1272916166.27948.62.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 03 May 2010 20:49:26 +0100

> On Mon, 2010-05-03 at 19:06 +0200, Eric Dumazet wrote:
> [...]
>> Current logic for drivers is to :
>> 
>> allocate skbs (sk_buff + data) and put them in a ring buffer.
> 
> Not all of them.

In particular NIU always allocates SKBs at the time that it passes the
packet up to the stack.
