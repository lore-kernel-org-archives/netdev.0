From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] forcedeth: Convert to use netdev_<level> and
 neatening
Date: Mon, 29 Nov 2010 11:51:57 -0800 (PST)
Message-ID: <20101129.115157.246510826.davem@davemloft.net>
References: <cover.1291051316.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	szymon@janc.net.pl, mirqus@gmail.com, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1291051316.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 29 Nov 2010 09:41:51 -0800

> Some mild restructuring and some generally neatening.
> 
> The conversions of dprintk to netdev_dbg in patches 2 and 4 are
> deleted in patch 10 as these seem to have been used only
> during initial development and are not normally compiled-in.
> 
> Patch 10 may be ignored if desired.
> 
> Object size is reduced ~2Kb overall.
> 
> $ size drivers/net/forcedeth.o.*
>    text	   data	    bss	    dec	    hex	filename
>   71739	    336	  17176	  89251	  15ca3	drivers/net/forcedeth.o.new
>   73416	    240	  17696	  91352	  164d8	drivers/net/forcedeth.o.old

These look fine, applied, thanks.
