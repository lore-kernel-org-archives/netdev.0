From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: caif: check return value of alloc_netdev
Date: Mon, 09 Nov 2015 11:31:41 -0500 (EST)
Message-ID: <20151109.113141.2248149943645747388.davem@davemloft.net>
References: <1447071550-20103-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447071550-20103-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Mon,  9 Nov 2015 13:19:10 +0100

> I don't know if dev can actually be NULL here, but the test should be
> above alloc_netdev(), to avoid leaking the struct net_device in case
> dev is actually NULL. And of course the return value from alloc_netdev
> should be tested.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
> Maybe the existing code was supposed to be "if (!ndev)", and dev
> cannot be NULL, but then -ENODEV is a slightly odd return
> value. Doing both tests seems to be the safe choice.

This is made painfully impossible to figure out because there seems
to be no in-tree code instantiating platform_device objects for
this caif_spi framework, nor are there even in-tree implementations
of the init_xfer et al. required methods.

So your fix is as good as any, applied, thanks.
