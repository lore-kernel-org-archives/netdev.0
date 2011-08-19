From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][Trivial] net/wan/hdlc_ppp: remove dead goto
Date: Thu, 18 Aug 2011 22:02:49 -0700 (PDT)
Message-ID: <20110818.220249.1523360015062657902.davem@davemloft.net>
References: <alpine.LNX.2.00.1108130138100.7387@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1108130138100.7387@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sat, 13 Aug 2011 01:39:43 +0200 (CEST)

> From: Jesper Juhl <jj@chaosbits.net>
> 
> We'll either hit one of the case labels or the default in the switch
> and in all cases do we then 'goto out', so having 'goto out' right
> after the switch is pointless as we can never hit it - remove it.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Probably a lot cleaner to use break statements in the switch() statement
and keep this goto in place.

That's more straightforward control flow than what this thing is doing.
