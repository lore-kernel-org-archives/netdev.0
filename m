From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 31 May 2015 21:35:54 -0700 (PDT)
Message-ID: <20150531.213554.1200774935717475775.davem@davemloft.net>
References: <20150601134413.34ccfce3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	saeedm@mellanox.com, ranas@mellanox.com, achiad@mellanox.com,
	amirv@mellanox.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150601134413.34ccfce3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 1 Jun 2015 13:44:13 +1000

> After merging the net-next tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> drivers/net/ethernet/mellanox/mlx5/core/main.c: In function 'mlx5_irq_set_affinity_hint':
> drivers/net/ethernet/mellanox/mlx5/core/main.c:474:2: error: implicit declaration of function 'cpumask_set_cpu_local_first' [-Werror=implicit-function-declaration]
>   err = cpumask_set_cpu_local_first(i, numa_node, priv->irq_info[i].mask);
>   ^
> 
> Caused by commit db058a186f98 ("net/mlx5_core: Set irq affinity hints")
> interacting with commit f36963c9d3f6 ("cpumask_set_cpu_local_first =>
> cpumask_local_spread, lament") from Linus' tree.
> 
> I have applied the following merge fix patch (Dave, you could do this
> by back merging commit f36963c9d3f6 from Linus' tree - which is based
> on v4.1-rc2 if that worries you).  Please yell if this is not correct
> (it does build).

Thanks Stephen, I'll take care of this next time I merge.
