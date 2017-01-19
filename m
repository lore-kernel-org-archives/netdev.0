From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Thu, 19 Jan 2017 10:26:35 +0200
Message-ID: <2de655ca-5bc5-2f87-4268-dfdf77141cb0@gmail.com>
References: <20170119095600.6d7a84d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170119095600.6d7a84d7@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 19/01/2017 12:56 AM, Stephen Rothwell wrote:
> Hi all,
>
> After merging the net tree, today's linux-next build (x86_64 allmodconfig)
> produced this warning:
>
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: In function 'mlx5e_set_channels':
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:546:6: warning: unused variable 'ncv' [-Wunused-variable]
>    int ncv = mlx5e_get_max_num_channels(priv->mdev);
>        ^
>
> Introduced by commit
>
>    639e9e94160e ("net/mlx5e: Remove unnecessary checks when setting num channels")
>
> which removed the last reference to 'ncv'.
>
We will send a fix shortly.
Thanks for your report!

Regards,
Tariq
