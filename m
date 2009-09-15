From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: kmemcheck: Caught 32-bit read from uninitialized
 memory (bf438284)
Date: Tue, 15 Sep 2009 02:39:39 -0700 (PDT)
Message-ID: <20090915.023939.194852114.davem@davemloft.net>
References: <20090915080953.GA24958@elte.hu>
	<4AAF5757.30500@gmail.com>
	<20090915093440.GA7921@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, penberg@cs.helsinki.fi,
	vegard.nossum@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975AbZIOJjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 05:39:22 -0400
In-Reply-To: <20090915093440.GA7921@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 15 Sep 2009 11:34:40 +0200

> 
> * Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Either we add kmemcheck annotations, or we switch sock->type from short
>> to int to avoid the hole, and possibly to speedup things...
>> 
>> [PATCH] net: kmemcheck annotation in struct socket
>> 
>> struct socket has a 16 bit hole that triggers kmemcheck warnings.
>> 
>> As suggested by Ingo, use kmemcheck annotations
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  include/linux/net.h |    5 +++++
>>  net/socket.c        |    1 +
>>  2 files changed, 6 insertions(+)
> 
> Acked-by: Ingo Molnar <mingo@elte.hu>

Applied, thanks everyone.
