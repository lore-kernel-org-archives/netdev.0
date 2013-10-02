From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: eicon: free pointer after using it in log msg in
 divas_um_idi_delete_entity()
Date: Wed, 02 Oct 2013 16:01:19 -0400 (EDT)
Message-ID: <20131002.160119.576160745622423553.davem@davemloft.net>
References: <alpine.LNX.2.00.1309302119550.4992@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1309302119550.4992@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Mon, 30 Sep 2013 21:25:27 +0200 (CEST)

> Not really a problem, but nice IMHO; the Coverity static analyzer
> complains that we use the pointer 'e' after it has been freed, so move
> the freeing below the final use, even if that use is just using the
> value of the pointer and not actually dereferencing it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied to net-next, thanks.
