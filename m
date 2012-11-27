From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] net: cpts: fix for build break after ARM SoC
 integration
Date: Tue, 27 Nov 2012 13:47:09 +0100
Message-ID: <20121127124708.GA31484@netboy.at.omicron.at>
References: <1354012034-31686-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	b-cousson@ti.com, paul@pwsan.com
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354012034-31686-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 03:57:14PM +0530, Mugunthan V N wrote:
>   CC      drivers/net/ethernet/ti/cpts.o
> drivers/net/ethernet/ti/cpts.c:30:24: fatal error: plat/clock.h: No such file or directory
> compilation terminated.
> make[4]: *** [drivers/net/ethernet/ti/cpts.o] Error 1
> make[3]: *** [drivers/net/ethernet/ti] Error 2
> make[2]: *** [drivers/net/ethernet] Error 2
> make[1]: *** [drivers/net] Error 2
> 
> fix for build break as the header file is removed from plat-omap as part of
> the below patch

Acked-by: Richard Cochran <richardcochran@gmail.com>
