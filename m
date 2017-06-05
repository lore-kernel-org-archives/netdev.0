From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] devlink: fix potential memort leak
Date: Mon, 05 Jun 2017 11:28:21 -0400 (EDT)
Message-ID: <20170605.112821.608113849627100528.davem@davemloft.net>
References: <1496624241-25794-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arkadis@mellanox.com, jiri@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496624241-25794-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Mon,  5 Jun 2017 08:57:21 +0800

> We must free allocated skb when genlmsg_put() return fails.
> 
> Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> ---
> Changes in v2:
>   - Fix same issue in headers_fill.

Applied, thank you.
