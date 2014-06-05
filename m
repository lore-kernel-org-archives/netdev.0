From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix sparse warning in fixed.c
Date: Thu, 05 Jun 2014 15:39:11 -0700 (PDT)
Message-ID: <20140605.153911.1518747275654141729.davem@davemloft.net>
References: <1401992862-8427-1-git-send-email-bergo.torino@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bergo.torino@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401992862-8427-1-git-send-email-bergo.torino@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konrad Zapalowicz <bergo.torino@gmail.com>
Date: Thu,  5 Jun 2014 20:27:42 +0200

> This commit fixes the following sparse warning:
> 
> drivers/net/phy/fixed.c:207
>     - warning: symbol 'fixed_phy_del' was not declared.
>       Should it be static?
> 
> by adding symbol definition to the phy_fixed.h API file. It is ok to do
> because the function in question is an exported symbol.
> 
> Signed-off-by: Konrad Zapalowicz <bergo.torino@gmail.com>

Applied to net-next, thanks.
