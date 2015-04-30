From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: Re: [PATCH net] net/bonding: Fix code style issues in a previous
 commit
Date: Thu, 30 Apr 2015 11:16:02 +0200
Message-ID: <5541F2D2.8070002@blackwall.org>
References: <E1Ynbux-0004Zy-Jn@bos-lpqrs.kendall.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Pai <vpai@akamai.com>, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E1Ynbux-0004Zy-Jn@bos-lpqrs.kendall.corp.akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/30/2015 02:01 AM, Pai wrote:
> This fixes a few coding style issues in my previous patch:
> commit e913fb279c56
> ("net: Fix Kernel Panic in bonding driver debugfs file: rlb_hash_table")
> 
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index d5fe5d5..ab3eeb1 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4543,8 +4543,8 @@ unsigned int bond_get_num_tx_queues(void)
>   */
>  int bond_create(struct net *net, const char *name)
>  {
> -	struct net_device *bond_dev;
>  	struct bonding *bond;
> +	struct net_device *bond_dev;
>  	struct alb_bond_info *bond_info;
>  	int res;
>  
> @@ -4559,8 +4559,7 @@ int bond_create(struct net *net, const char *name)
>  		return -ENOMEM;
>  	}
>  
> -	/*
> -	 * Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
> +	/* Initialize rx_hashtbl_used_head to RLB_NULL_INDEX.
>  	 * It is set to 0 by default which is wrong.
>  	 */
>  	bond = netdev_priv(bond_dev);
> 

Hi,
Thanks for following up on my comments, but I think Dave usually prefers
such cosmetic changes via net-next, of course that's for him to say. For
the local variable arrangement I meant longest to shortest as in reverse
pyramid:
  	struct alb_bond_info *bond_info;
	struct net_device *bond_dev;
  	struct bonding *bond;
  	int res;

Cheers,
 Nik
