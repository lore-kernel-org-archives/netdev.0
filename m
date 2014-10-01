From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Fix build warning for !PM_SLEEP
Date: Wed, 01 Oct 2014 15:24:52 -0400 (EDT)
Message-ID: <20141001.152452.1973501659924138094.davem@davemloft.net>
References: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <thierry.reding@gmail.com>
Date: Wed,  1 Oct 2014 13:59:00 +0200

> From: Thierry Reding <treding@nvidia.com>
> 
> The dsa_switch_suspend() and dsa_switch_resume() functions are only used
> when PM_SLEEP is enabled, so they need #ifdef CONFIG_PM_SLEEP protection
> to avoid a compiler warning.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Applied.

Please, in the future, explicitly indicate what tree your changes
are against.  Through trial and error I figured out that this could
only apply to net-next, but that's not a good use of my time.

Thanks.
