From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] rionet: use free_netdev(netdev) instead of kfree()
Date: Sun, 26 Sep 2010 18:55:06 -0700 (PDT)
Message-ID: <20100926.185506.116382972.davem@davemloft.net>
References: <1285495083-21899-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, tj@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285495083-21899-1-git-send-email-segooon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segooon@gmail.com>
Date: Sun, 26 Sep 2010 13:58:03 +0400

> Freeing netdev without free_netdev() leads to net, tx leaks.
> I might lead to dereferencing freed pointer.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> @@
> struct net_device* dev;
> @@
> 
> -kfree(dev)
> +free_netdev(dev)

Applied.
