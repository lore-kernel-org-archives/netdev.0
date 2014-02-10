From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][Trivial] tcp: correct code comment stating 3 min
 timeout for FIN_WAIT2, we only do 1 min
Date: Sun, 09 Feb 2014 19:14:53 -0800 (PST)
Message-ID: <20140209.191453.505244720024526564.davem@davemloft.net>
References: <alpine.LNX.2.00.1402092328270.8418@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1402092328270.8418@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 9 Feb 2014 23:30:32 +0100 (CET)

> As far as I can tell we have used a default of 60 seconds for
> FIN_WAIT2 timeout for ages (since 2.x times??).
> 
> In any case, the timeout these days is 60 seconds, so the 3 min
> comment is wrong (and cost me a few minutes of my life when I was
> debugging a FIN_WAIT2 related problem in a userspace application and
> checked the kernel source for details).
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied, thanks.
