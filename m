From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] qlcnic_dcb.c : possible division by zero.
Date: Wed, 25 Feb 2015 17:01:06 -0500 (EST)
Message-ID: <20150225.170106.798587659082519733.davem@davemloft.net>
References: <1424901403-6458-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ameenali023@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424901403-6458-1-git-send-email-ameenali023@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ameen Ali <ameenali023@gmail.com>
Date: Wed, 25 Feb 2015 23:56:43 +0200

> @@ -822,7 +822,7 @@ qlcnic_dcb_get_pg_tc_cfg_tx(struct net_device *netdev, int tc, u8 *prio,
>  		if (temp->valid && (pg == temp->pgid))
>  			cnt++;
>  	}
> -
> +	if(cnt != 0)
>  	tc_cfg->bwg_percent = (100 / cnt);

This is not acceptable.

Your conditional expression is not spaced properly, there must be a space
between "if" and the openning parenthesis of the condition.

You also must properly re-indent the statement the new if() condition
is protecting.
