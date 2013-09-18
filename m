From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tsi108: Prevent compiler warning
Date: Wed, 18 Sep 2013 12:38:53 -0400 (EDT)
Message-ID: <20130918.123853.1464055976885078627.davem@davemloft.net>
References: <1379508595-30252-1-git-send-email-treding@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379508595-30252-1-git-send-email-treding@nvidia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed, 18 Sep 2013 14:49:55 +0200

> The dump_eth_one() function is only used if DEBUG is enabled, so protect
> it by a corresponding #ifdef DEBUG block.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

I would prefer that this function and the one call site is simply
removed instead.

This kind of thing can be provided via ethtool register dumps
and therefore without all of the ugliness this ad-hoc stuff
presents.
