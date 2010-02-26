From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] drivers/net/chelsio: Use pr_<level>,
 netif_msg_<type>
Date: Fri, 26 Feb 2010 01:40:10 -0800 (PST)
Message-ID: <20100226.014010.239722623.davem@davemloft.net>
References: <cover.1266893507.git.joe@perches.com>
	<819e937a3feefb278c2816db2947eff95dd6740a.1266893507.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <819e937a3feefb278c2816db2947eff95dd6740a.1266893507.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 22 Feb 2010 18:56:57 -0800

> Convert CH_<level> and CH_DBG uses to pr_<level> and netif equivalents
> Remove CH_<level> and CH_DBG macro definitions
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.

BTW:

> @@ -734,8 +734,9 @@ int t1_elmer0_ext_intr_handler(adapter_t *adapter)
>  		break;
>  	case CHBT_BOARD_8000:
>  	case CHBT_BOARD_CHT110:
> -		CH_DBG(adapter, INTR, "External interrupt cause 0x%x\n",
> -		       cause);
> +		if (netif_msg_intr(adapter))
> +			dev_dbg(&adapter->pdev->dev, 

Trailing whitespace on that last line.  I fixed it up when
adding the patch to my tree.
