From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: add ethtool support for set and
 get of settings
Date: Mon, 29 Feb 2016 17:09:10 -0500 (EST)
Message-ID: <20160229.170910.1568620456454101151.davem@davemloft.net>
References: <1456442648-13941-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1456442648-13941-1-git-send-email-sixiao@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Simon Xiao <sixiao@microsoft.com>
Date: Thu, 25 Feb 2016 15:24:08 -0800

> This patch allows the user to set and retrieve speed and duplex of the
> hv_netvsc device via ethtool.
> 
> Example:
> $ ethtool eth0
> Settings for eth0:
> ...
>     Speed: Unknown!
>     Duplex: Unknown! (255)
> ...
> $ ethtool -s eth0 speed 1000 duplex full
> $ ethtool eth0
> Settings for eth0:
> ...
>     Speed: 1000Mb/s
>     Duplex: Full
> ...
> 
> This is based on patches by Roopa Prabhu and Nikolay Aleksandrov.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>

Applied, thanks.
