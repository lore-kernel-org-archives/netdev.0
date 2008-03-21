From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 (spin 2) resend] TCP_DEFER_ACCEPT updates - process
 as established
Date: Fri, 21 Mar 2008 16:34:03 -0700 (PDT)
Message-ID: <20080321.163403.160241605.davem@davemloft.net>
References: <1206053493.13044.14.camel@tng>
	<1206053758.13044.24.camel@tng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcmanus@ducksong.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbYCUXdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 19:33:47 -0400
In-Reply-To: <1206053758.13044.24.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McManus <mcmanus@ducksong.com>
Date: Thu, 20 Mar 2008 18:55:58 -0400

> commit 4a234b7dd1a5144fe5630f1b0739e3c8c28de2ed
> Author: Patrick McManus <mcmanus@ducksong.com>
> Date:   Sun Mar 2 16:52:37 2008 -0500
> 
>     Change TCP_DEFER_ACCEPT implementation so that it transitions a
>     connection to ESTABLISHED after handshake is complete instead of
>     leaving it in SYN-RECV until some data arrvies. Place connection in
>     accept queue when first data packet arrives from slow path.
>     
>     Benefits:
>       - established connection is now reset if it never makes it
>        to the accept queue
>     
>      - diagnostic state of established matches with the packet traces
>        showing completed handshake
>     
>      - TCP_DEFER_ACCEPT timeouts are expressed in seconds and can now be
>        enforced with reasonable accuracy instead of rounding up to next
>        exponential back-off of syn-ack retry.
>     
>     Signed-off-by: Patrick McManus <mcmanus@ducksong.com>

Applied and pushed to net-2.6.26, thanks.
