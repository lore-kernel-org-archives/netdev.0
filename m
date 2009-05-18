From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_prequeue() can use keyed wakeups
Date: Sun, 17 May 2009 20:45:16 -0700 (PDT)
Message-ID: <20090517.204516.101149899.davem@davemloft.net>
References: <1242178490.11389.20.camel@merlyn>
	<4A0A3E5A.6040702@cosmosbay.com>
	<1242227107.7145.13.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753621AbZERDpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:45:19 -0400
In-Reply-To: <1242227107.7145.13.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Wed, 13 May 2009 10:05:07 -0500

> On Wed, 2009-05-13 at 05:28 +0200, Eric Dumazet wrote:
> 
>> To see a benefit of this patch, we would need two threads, one blocked
>> in a recv(),
>> one blocked in a send() on same socket (or a poll/epoll user with same
>> bi-directional trafic)
> 
> Agreed.

I've applied this to net-next-2.6, thanks.
