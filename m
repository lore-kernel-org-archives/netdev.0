From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Wed, 02 Nov 2011 19:13:24 -0400 (EDT)
Message-ID: <20111102.191324.1716703336141439504.davem@davemloft.net>
References: <20111102224317.GM31337@atomide.com>
	<4EB1CA4F.3090403@gmail.com>
	<20111102.190955.1902322759075682192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab1KBXN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 19:13:27 -0400
In-Reply-To: <20111102.190955.1902322759075682192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 02 Nov 2011 19:09:55 -0400 (EDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Nov 2011 23:55:11 +0100
> 
>> There is a problem with your kmalloc() or alignments on your architecture.
>> 
>> What is the SMP_CACHE_BYTES value ?
> 
> kmalloc() behavior doesn't have anything to do with this bug.

Sorry, I take that back, I see now how ksize() and friends are being
used here.
