From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 10/16] drivers/net/ethernet/ibm/emac/mal.c: use WARN
Date: Sat, 3 Nov 2012 17:35:07 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1211031733330.1955@localhost6.localdomain6>
References: <1351940317-14812-1-git-send-email-Julia.Lawall@lip6.fr> <1351940317-14812-11-git-send-email-Julia.Lawall@lip6.fr> <50950055.8040307@bfs.de> <alpine.DEB.2.02.1211031513220.1955@localhost6.localdomain6> <509545C0.5050000@bfs.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509545C0.5050000@bfs.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> While looking i have noticed that a lot of drivers define there private "assert" macro.
> It is very similar to warn.
>
> (e.g.)
> #define RTL819x_DEBUG
> #ifdef RTL819x_DEBUG
> #define assert(expr) \
>        if (!(expr)) {                                  \
>                 printk( "Assertion failed! %s,%s,%s,line=%d\n", \
>                #expr,__FILE__,__FUNCTION__,__LINE__);          \
>        }

WARN is more complicated.  At least with the right debugging options 
turned on, it dumps the stack, via warn_slowpath_common.

julia
