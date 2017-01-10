From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netcp: correct netcp_get_stats function signature
Date: Tue, 10 Jan 2017 11:52:13 -0500 (EST)
Message-ID: <20170110.115213.1856085394233309828.davem@davemloft.net>
References: <1484047585-16733-1-git-send-email-j-keerthy@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, stephen@networkplumber.org,
        m-scherban@ti.com
To: j-keerthy@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484047585-16733-1-git-send-email-j-keerthy@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keerthy <j-keerthy@ti.com>
Date: Tue, 10 Jan 2017 16:56:25 +0530

> @@ -1909,7 +1909,7 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
>  	return 0;
>  }
>  
> -static struct rtnl_link_stats64 *
> +void
>  netcp_get_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)

Please do not remove the static qualifier.
