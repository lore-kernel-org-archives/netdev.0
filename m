From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 resend] TCP_DEFER_ACCEPT updates - defer timeout
 conflicts with max_thresh
Date: Fri, 21 Mar 2008 16:28:21 -0700 (PDT)
Message-ID: <20080321.162821.225728823.davem@davemloft.net>
References: <1206053738.13044.21.camel@tng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcmanus@ducksong.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750785AbYCUX2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 19:28:05 -0400
In-Reply-To: <1206053738.13044.21.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McManus <mcmanus@ducksong.com>
Date: Thu, 20 Mar 2008 18:55:38 -0400

> commit 077b5f8e36b93e5121f680c3bb327e7464020fd2
> Author: Patrick McManus <mcmanus@ducksong.com>
> Date:   Sat Feb 23 12:23:47 2008 -0500
> 
>     timeout associated with SO_DEFER_ACCEPT wasn't being honored if it was
>     less than the timeout allowed by the maximum syn-recv queue size
>     algorithm. Fix by using the SO_DEFER_ACCEPT value if the ack has
>     arrived.
>     
>     Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
>     Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.26, thanks.
