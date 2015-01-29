From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: deflate: never return len larger than output
 buffer
Date: Thu, 29 Jan 2015 14:50:29 -0800 (PST)
Message-ID: <20150129.145029.2079802415674560097.davem@davemloft.net>
References: <1422438964-7937-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbbA2Wua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:50:30 -0500
In-Reply-To: <1422438964-7937-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 28 Jan 2015 10:56:04 +0100

> When we've run out of space in the output buffer to store more data, we
> will call zlib_deflate with a NULL output buffer until we've consumed
> remaining input.
> 
> When this happens, olen contains the size the output buffer would have
> consumed iff we'd have had enough room.
> 
> This can later cause skb_over_panic when ppp_generic skb_put()s
> the returned length.
> 
> Reported-by: Iain Douglas <centos@1n6.org.uk>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks Florian.
