From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove redundant linux/version.h includes from net/
Date: Tue, 21 Jun 2011 16:03:34 -0700 (PDT)
Message-ID: <20110621.160334.1438754754048406782.davem@davemloft.net>
References: <alpine.LNX.2.00.1106210009520.27735@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, coreteam@netfilter.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, xeb@mail.ru
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106210009520.27735@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Tue, 21 Jun 2011 00:13:10 +0200 (CEST)

> It was suggested by "make versioncheck" that the follwing includes of
> linux/version.h are redundant:
> 
>   /home/jj/src/linux-2.6/net/caif/caif_dev.c: 14 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/caif/chnl_net.c: 10 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/ipv4/gre.c: 19 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/netfilter/ipset/ip_set_core.c: 20 linux/version.h not needed.
>   /home/jj/src/linux-2.6/net/netfilter/xt_set.c: 16 linux/version.h not needed.
> 
> and it seems that it is right.
> 
> Beyond manually inspecting the source files I also did a few build
> tests with various configs to confirm that including the header in
> those files is indeed not needed.
> 
> Here's a patch to remove the pointless includes.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied, thanks.
