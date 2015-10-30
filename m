From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] RDS: convert bind hash table to re-sizable
 hashtable
Date: Fri, 30 Oct 2015 20:15:36 +0900 (KST)
Message-ID: <20151030.201536.285461609251750460.davem@davemloft.net>
References: <1446072672-4325-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446072672-4325-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Wed, 28 Oct 2015 15:51:12 -0700

> +					    &rs->rs_bound_node, ht_parms)) {
>  			*port = rs->rs_bound_port;
>  			ret = 0;
>  			rdsdebug("rs %p binding to %pI4:%d\n",
>  			  rs, &addr, (int)ntohs(*port));
>  			break;
>  		} else {
> -			rds_sock_put(rrs);
> +			rds_sock_put(rs);
> +			ret = -ENOMEM;
> +			break;
>  		}
> +
>  	} while (rover++ != last);
>  
>  	return ret;

This final insert of an empty line is both inappropriate and even
if it was it would not be related to this change.
