From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: core: remove TX_LOCKED support
Date: Tue, 26 Apr 2016 15:53:29 -0400 (EDT)
Message-ID: <20160426.155329.174600162183067810.davem@davemloft.net>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Sun, 24 Apr 2016 21:38:08 +0200

>  Not that many users left, lets kill it.
> 
>  TX_LOCKED was meant to be used by LLTX drivers when spin_trylock()
>  failed.  Stack then re-queued if collisions happened on different
>  cpus or free'd the skb to prevent deadlocks.
> 
>  Most of the driver removal patches fall into one of three categories:
>  1. remove the driver-private tx lock (and LLTX flag), or...
>  2. convert spin_trylock to plain spin_lock, or...
>  3. convert TX_LOCKED to free+TX_OK
> 
>  Patches are grouped by these categories, last patch is the actual removal.
>  All driver changes were compile tested only with exception of atl1e.

This looks good to me, series applied, thanks Florian.
