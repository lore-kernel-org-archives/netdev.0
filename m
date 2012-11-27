From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] net: ethernet: cpsw: fix build warnings for CPSW
 when CPTS not selected
Date: Tue, 27 Nov 2012 19:31:30 +0100
Message-ID: <20121127183130.GA7278@netboy.at.omicron.at>
References: <1354038820-11095-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354038820-11095-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2012 at 11:23:40PM +0530, Mugunthan V N wrote:
>   CC      drivers/net/ethernet/ti/cpsw.o
> drivers/net/ethernet/ti/cpsw.c: In function 'cpsw_ndo_ioctl':
> drivers/net/ethernet/ti/cpsw.c:881:20: warning: unused variable 'priv'
> 
> The build warning is generated when CPTS is not selected in Kernel Build.
> Fixing by passing the net_device pointer to cpts IOCTL instead of passing priv
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Thanks for this fix.

Acked-by: Richard Cochran <richardcochran@gmail.com>
