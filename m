From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/qla3xxx.c: Update logging message
 style
Date: Sun, 25 Jul 2010 22:03:40 -0700 (PDT)
Message-ID: <20100725.220340.115945473.davem@davemloft.net>
References: <4057a685dc2c277e9e3137c4f0e01eeb389971a4.1279837596.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4057a685dc2c277e9e3137c4f0e01eeb389971a4.1279837596.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 22 Jul 2010 15:33:31 -0700

> Use pr_<level>
> Use netdev_<level>
> Use netif_<level>
> Remove #define PFX
> Improve a couple of loops to avoid deep indentation.
> 
> Compile tested only
> 
> $ size drivers/net/qla3xxx.o.*
>    text    data     bss     dec     hex filename
>   51603     212   13864   65679   1008f drivers/net/qla3xxx.o.old
>   50413     212   13864   64489    fbe9 drivers/net/qla3xxx.o.new
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
