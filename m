From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: remove incorrect EFX_BUG_ON_PARANOID check
Date: Wed, 22 Oct 2014 12:51:42 -0400 (EDT)
Message-ID: <20141022.125142.451723084641542402.davem@davemloft.net>
References: <alpine.LFD.2.03.1410211353290.26215@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sshah@solarflare.com,
	jcooper@solarflare.com, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbaJVQvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:51:44 -0400
In-Reply-To: <alpine.LFD.2.03.1410211353290.26215@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 21 Oct 2014 14:50:29 +0100

> From: Jon Cooper <jcooper@solarflare.com>
> 
> write_count and insert_count can wrap around, making > check invalid.
> 
> Fixes: 70b33fb0ddec827cbbd14cdc664fc27b2ef4a6b6 ("sfc: add support for
>  skb->xmit_more").
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
