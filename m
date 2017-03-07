From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net-next] net: dwc-xlgmac: Initial driver for
 DesignWare Enterprise Ethernet
Date: Tue, 07 Mar 2017 12:34:06 -0800 (PST)
Message-ID: <20170307.123406.1777577205348543307.davem@davemloft.net>
References: <9c5935b28ca61ec4ceb20bac0cc830e2e57028b9.1488331400.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jie.Deng1@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9c5935b28ca61ec4ceb20bac0cc830e2e57028b9.1488331400.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jie Deng <Jie.Deng1@synopsys.com>
Date: Wed, 1 Mar 2017 12:00:25 +0800

> +static int xlgmac_init(struct xlgmac_pdata *pdata)
> +{
> +	struct net_device *netdev = pdata->netdev;
> +	struct xlgmac_hw_ops *hw_ops = &pdata->hw_ops;

Please order local variable declarations from longest to shortest line.

Please fix this in your entire submission.

> +
> +err_netdev_register:
> +err_init:

Avoid multiple error labels in the same exact location, by having only
one which describes what the error path unwinds.  For example,  here you
could say "err_free_netdev".

Please fix this up in your entire submission.
