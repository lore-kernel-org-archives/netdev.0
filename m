From: David Miller <davem@davemloft.net>
Subject: Re: Kernel-DOS error in arp mechanism
 =?iso-2022-jp-3?B?GyQoUSN8GyhC?= no delete off incomplete arp adresses
Date: Wed, 21 Dec 2011 03:07:27 -0500 (EST)
Message-ID: <20111221.030727.1528369698756365464.davem@davemloft.net>
References: <4EEC5286.3070408@gmx.de>
	<CAFLxGvxjLCyMCPXtpm7a7RaOL4A4=bhCLPKD=FVAc8xOdx_CsQ@mail.gmail.com>
	<1324453467.2610.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.weinberger@gmail.com, gladewitz@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324453467.2610.20.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 08:44:27 +0100

> David, I suggest we add back the garbage collector for current kernels,
> we'll remove it when route cache really disappear ?
> 
> I'll send a patch today.

Yes, it's the best idea.

We can actually remove it again as early as when when route neigh's
are ref-less.
