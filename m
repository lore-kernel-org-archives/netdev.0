From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/packet: remove dead code and unneeded variable
 from prb_setup_retire_blk_timer()
Date: Mon, 14 Nov 2011 00:09:30 -0500 (EST)
Message-ID: <20111114.000930.2208688710577745372.davem@davemloft.net>
References: <alpine.LNX.2.00.1111132247440.3368@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, xiaosuo@gmail.com, greearb@candelatech.com,
	loke.chetan@gmail.com, waltje@uWalt.NL.Mugnet.ORG,
	gw4pts@gw4pts.ampr.org, waltje@linux.com, ross.biro@gmail.com,
	alan@linux.intel.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1111132247440.3368@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 13 Nov 2011 22:55:50 +0100 (CET)

> We test for 'tx_ring' being != zero and BUG() if that's the case. So after
> that check there is no way that 'tx_ring' could be anything _but_ zero, so
> testing it again is just dead code. Once that dead code is removed, the
> 'pkc' local variable becomes entirely redundant, so remove that as well.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied, thanks Jesper.
