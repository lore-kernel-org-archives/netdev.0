From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: linux-next: manual merge of the rdma tree with the net-next tree
Date: Tue, 5 Jan 2016 19:05:24 +0200
Message-ID: <568BF7D4.8080304@mellanox.com>
References: <20160105125154.36d9a0c4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Doug Ledford <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160105125154.36d9a0c4@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/5/2016 3:51 AM, Stephen Rothwell wrote:
> Hi Doug,
>
> Today's linux-next merge of the rdma tree got conflicts in:
>
>    drivers/net/ethernet/mellanox/mlx5/core/vport.c
>    include/linux/mlx5/mlx5_ifc.h
>    include/linux/mlx5/vport.h
>
> between commits:
>
>    e1d7d349c69d ("net/mlx5: Update access functions to Query/Modify vport MAC address")
>    e75465148b7d ("net/mlx5: Introduce access functions to modify/query vport state")
>
> from the net-next tree and commit:
>
>    e5f6175c5b66 ("net/mlx5_core: Break down the vport mac address query function")
>
> from the rdma tree and maybe some others.
>
> I have no hope of fixing this stuff up, so I have dropped the rdma tree
> again for today.  There is similar functionality being introduced in
> both trees ... please sort this mess out ...

Hi Stephen,

Saeed/Matan and Co are working here on a fix which would solve the 
conflict.

We have the basic patch and people will be testing it later/tomorrow.

Could you please advice how would it be possible to provide you the
git rerere output -- the pre-image and post-images files from .git/rr-cache?

Or.
