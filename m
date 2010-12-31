From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/atm/atmtcp.c: add missing atm_dev_put
Date: Fri, 31 Dec 2010 12:52:23 -0800 (PST)
Message-ID: <20101231.125223.212690412.davem@davemloft.net>
References: <Pine.LNX.4.64.1012291500310.8559@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1012291500310.8559@pc-004.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Wed, 29 Dec 2010 15:01:03 +0100 (CET)

> From: Julia Lawall <julia@diku.dk>
> 
> The earlier call to atm_dev_lookup increases the reference count of dev,
> so decrease it on the way out.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thank you.
