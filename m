From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [linux-sunxi] [PATCH] net-next: stmmac: dwmac-sun8i: ensure the
 EPHY is properly reseted
Date: Mon, 5 Jun 2017 13:10:19 +0200
Message-ID: <20170605111019.GA29657@Red>
References: <20170604175323.62124-1-icenowy@aosc.io>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-sunxi@googlegroups.com
To: Icenowy Zheng <icenowy@aosc.io>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170604175323.62124-1-icenowy@aosc.io>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2017 at 01:53:23AM +0800, Icenowy Zheng wrote:
> The EPHY may be already enabled by bootloaders which have Ethernet
> capability (e.g. current U-Boot). Thus it should be reseted properly
> before doing the enabling sequence in the dwmac-sun8i driver, otherwise
> the EMAC reset process may fail if no cable is plugged, and then fail
> the dwmac-sun8i probing.
> 
> Tested on Orange Pi PC, One and Zero. All the boards fail to have
> dwmac-sun8i probed with "EMAC reset timeout" without cable plugged
> before, and with this fix they're now all able to successfully probe the
> EMAC without cable plugged and then use the connection after a cable is
> hot-plugged in.
> 
> Fixes: 9f93ac8d408 ("net-next: stmmac: Add dwmac-sun8i")
> Signed-off-by: Icenowy Zheng <icenowy@aosc.io>

Thanks for the fix.
Tested-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Since I am the writter of the file, does I have the right to:
Acked-by: Corentin Labbe <clabbe.montjoie@gmail.com>
or
Reviewed-by: Corentin Labbe <clabbe.montjoie@gmail.com>
?

Perhaps I need to set myself as reviewer for this file in MAINTAINERS ?
Regards
