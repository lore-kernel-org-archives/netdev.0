From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: r8a779x: Enable automatically fetch receive
 descriptor
Date: Thu, 13 Nov 2014 15:03:11 -0500 (EST)
Message-ID: <20141113.150311.1961794581032201784.davem@davemloft.net>
References: <1415861819-27812-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org, grant.likely@linaro.org
To: ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415861819-27812-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Thu, 13 Nov 2014 15:56:59 +0900

> From: Kouei Abe <kouei.abe.cp@renesas.com>
> 
> HDMAC automatically fetches the receive descriptor and receives frames.
> Continuous reception of multiple frames is possible.
> 
> Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> ---
> 
> This patch is based on net-next tree.

This doesn't even compile, or, it depends upon another patch which you have
not mentioned.

Because sh_eth_cpu_data does not have an rmcr_value field.
