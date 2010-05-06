From: David Miller <davem@davemloft.net>
Subject: Re: tip: origin tree boot crash (in the new micrel phy driver)
Date: Thu, 06 May 2010 03:10:40 -0700 (PDT)
Message-ID: <20100506.031040.186321896.davem@davemloft.net>
References: <20100505.012750.246538504.davem@davemloft.net>
	<20100506095940.GA12711@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.choi@micrel.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100506095940.GA12711@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 6 May 2010 11:59:40 +0200

> I bisected it back to the following commit:
> 
> d05070091849015f8c5b7d55cd75b86ebb61b3ec is the first bad commit
> commit d05070091849015f8c5b7d55cd75b86ebb61b3ec
> Author: David J. Choi <david.choi@micrel.com>
> Date:   Thu Apr 29 06:12:41 2010 +0000
> 
>     drivers/net/phy: micrel phy driver
>     
>     This is the first version of phy driver from Micrel Inc.
>     
>     Signed-off-by: David J. Choi <david.choi@micrel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> the config had:
> 
>   CONFIG_MICREL_PHY=y
> 
> Disabling the driver fixes the crash.

David please fix this crash, thanks.
