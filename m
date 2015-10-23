From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] allow dctcp alpha to drop to zero
Date: Fri, 23 Oct 2015 02:47:20 -0700 (PDT)
Message-ID: <20151023.024720.1261240812356446593.davem@davemloft.net>
References: <20151019045908.GB11368@mininet-vm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, fw@strlen.de,
	glenn.judd@morganstanley.com
To: agshew@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbJWJau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:30:50 -0400
In-Reply-To: <20151019045908.GB11368@mininet-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Shewmaker <agshew@gmail.com>
Date: Sun, 18 Oct 2015 21:59:08 -0700

> If alpha is strictly reduced by alpha >> dctcp_shift_g and if alpha is less
> than 1 << dctcp_shift_g, then alpha may never reach zero. For example,
> given shift_g=4 and alpha=15, alpha >> dctcp_shift_g yields 0 and alpha
> remains 15. The effect isn't noticeable in this case below cwnd=137, but
> could gradually drive uncongested flows with leftover alpha down to
> cwnd=137. A larger dctcp_shift_g would have a greater effect.
> 
> This change causes alpha=15 to drop to 0 instead of being decrementing by 1
> as it would when alpha=16. However, it requires one less conditional to
> implement since it doesn't have to guard against subtracting 1 from 0U. A
> decay of 15 is not unreasonable since an equal or greater amount occurs at
> alpha >= 240.
> 
> Signed-off-by: Andrew G. Shewmaker <agshew@gmail.com>

Applied, thanks.
