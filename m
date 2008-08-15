From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: skb_copy_datagram_from_iovec()
Date: Fri, 15 Aug 2008 15:14:00 -0700 (PDT)
Message-ID: <20080815.151400.217147910.davem@davemloft.net>
References: <200808121624.56948.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
	herbert@gondor.apana.org.au
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbYHOWOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 18:14:01 -0400
In-Reply-To: <200808121624.56948.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 12 Aug 2008 16:24:56 +1000

> There's an skb_copy_datagram_iovec() to copy out of a paged skb, but
> nothing the other way around (because we don't do that).
> 
> We want to allocate big skbs in tun.c, so let's add the function.
> It's a carbon copy of skb_copy_datagram_iovec() with enough changes to
> be annoying.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
