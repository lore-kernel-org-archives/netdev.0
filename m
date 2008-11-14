From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: speedup dst_release()
Date: Fri, 14 Nov 2008 00:54:37 -0800 (PST)
Message-ID: <20081114.005437.09284570.davem@davemloft.net>
References: <491D323B.9030802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60351
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750734AbYKNIyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 03:54:38 -0500
In-Reply-To: <491D323B.9030802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 14 Nov 2008 09:09:31 +0100

> During tbench/oprofile sessions, I found that dst_release() was in third position.
 ...
> Instead of first checking the refcount value, then decrement it,
> we use atomic_dec_return() to help CPU to make the right memory transaction
> (ie getting the cache line in exclusive mode)
 ...
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

This looks great, applied, thanks Eric.
