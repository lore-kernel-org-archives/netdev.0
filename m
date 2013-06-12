From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: split 'sh_eth_netdev_ops'
Date: Wed, 12 Jun 2013 14:16:06 -0700 (PDT)
Message-ID: <20130612.141606.1300633926770455407.davem@davemloft.net>
References: <201306130055.34780.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306130055.34780.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 13 Jun 2013 00:55:34 +0400

> Commit 9f86134155047720a3685cda21467f68695152d2 (sh_eth: remove SH_ETH_HAS_TSU)
> removes 'const' from 'sh_eth_netdev_ops'  and modifies it in case TSU registers
> are present. I've originally suggested to Iwamatsu-san to split  this structure
> in two instead and afterwards Dave M. suggested doing the same.
> Split 'sh_eth_netdev_ops_tsu' from 'sh_eth_netdev_ops', making both 'const', and
> assigning 'ndev->detdev_ops'  depending on the presence of TSU registers.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
