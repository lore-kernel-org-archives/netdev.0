From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 3/3] net: mv643xx_eth: fix missing device_node for port
 devices
Date: Wed, 2 Oct 2013 08:22:09 -0400
Message-ID: <20131002122209.GK31178@titan.lakedaemon.net>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1380711442-24735-4-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380711442-24735-4-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:57:22PM +0200, Sebastian Hesselbarth wrote:
> DT-based mv643xx_eth probes and creates platform_devices for the
> port devices on its own. To allow fixups for ports based on the
> device_node, we need to set .of_node of the corresponding device
> with the correct node.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: David Miller <davem@davemloft.net>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/ethernet/marvell/mv643xx_eth.c |    1 +
>  1 file changed, 1 insertion(+)

Acked-by: Jason Cooper <jason@lakedaemon.net>

thx,

Jason.
