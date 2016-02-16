From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smc91x: propagate irq return code
Date: Tue, 16 Feb 2016 15:02:52 -0500 (EST)
Message-ID: <20160216.150252.1405092489441801597.davem@davemloft.net>
References: <1454793800-7789-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454793800-7789-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat,  6 Feb 2016 22:23:20 +0100

> The smc91x driver doesn't honor the probe deferral mechanism when the
> interrupt source is not yet available, such as one provided by a gpio
> controller not probed.
> 
> Fix this by propagating the platform_get_irq() error code as the probe
> return value.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> ---
> Since v1: change the irq test to < 0

Applied, thanks.
