From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipconfig: Fix more use after free
Date: Wed, 17 Aug 2016 19:34:26 -0400 (EDT)
Message-ID: <20160817.193426.2273185535811000291.davem@davemloft.net>
References: <20160816144538.3181-1-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, geert+renesas@glider.be,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160816144538.3181-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@gmail.com>
Date: Tue, 16 Aug 2016 16:45:38 +0200

> From: Thierry Reding <treding@nvidia.com>
> 
> While commit 9c706a49d660 ("net: ipconfig: fix use after free") avoids
> the use after free, the resulting code still ends up calling both the
> ic_setup_if() and ic_setup_routes() after calling ic_close_devs(), and
> access to the device is still required.
> 
> Move the call to ic_close_devs() to the very end of the function.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
> This applies on top of next-20160816.

Applied, thanks.
