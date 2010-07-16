From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/mlx4: Use %pV, pr_<level>,
 printk_once
Date: Thu, 15 Jul 2010 19:07:34 -0700 (PDT)
Message-ID: <20100715.190734.245390906.davem@davemloft.net>
References: <baf5f3949ffd5a48a6f5667b6d6394e6d48c91ca.1278696312.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, yevgenyp@mellanox.co.il,
	jackm@dev.mellanox.co.il, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <baf5f3949ffd5a48a6f5667b6d6394e6d48c91ca.1278696312.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 10 Jul 2010 10:22:46 -0700

> Remove near duplication of format string constants by using the newly
> introduced vsprintf extention %pV to reduce text by 20k or so.
> 
> $ size drivers/net/mlx4/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  161367	   1866	  48784	 212017	  33c31	drivers/net/mlx4/built-in.o
>  142621	   1866	  46248	 190735	  2e90f	drivers/net/mlx4/built-in.o.new
> 
> Use printk_once as appropriate.
> Convert printks to pr_<level>, some bare printks now use pr_cont.
> Remove now unused #define PFX.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
