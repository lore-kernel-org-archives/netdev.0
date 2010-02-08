From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Mon, 08 Feb 2010 15:50:12 -0800 (PST)
Message-ID: <20100208.155012.224300482.davem@davemloft.net>
References: <20100208152606.91c55722.akpm@linux-foundation.org>
	<20100208.153406.123254133.davem@davemloft.net>
	<20100208153744.236158aa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43453
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752368Ab0BHXt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 18:49:58 -0500
In-Reply-To: <20100208153744.236158aa.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 8 Feb 2010 15:37:44 -0800

> On Mon, 08 Feb 2010 15:34:06 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> For a busy router, really, this is normal behavior.
> 
> Is the cache a net win in that scenario?

Absolutely.
