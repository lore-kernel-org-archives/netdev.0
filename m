From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 10/14] bluetooth: Use eth_<foo>_addr instead of memset
Date: Mon, 2 Mar 2015 23:04:27 -0800
Message-ID: <235052A1-0253-41FB-B381-FBC8B312ADE6@holtmann.org>
References: <cover.1425354527.git.joe@perches.com> <3e4a2efa6cbc9bea479bd3d8460ea56dda128faf.1425354528.git.joe@perches.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3e4a2efa6cbc9bea479bd3d8460ea56dda128faf.1425354528.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

> Use the built-in function instead of memset.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> net/bluetooth/bnep/netdev.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
> index 4b488ec..6ceb5d3 100644
> --- a/net/bluetooth/bnep/netdev.c
> +++ b/net/bluetooth/bnep/netdev.c
> @@ -218,7 +218,7 @@ static const struct net_device_ops bnep_netdev_ops = {
> void bnep_net_setup(struct net_device *dev)
> {
> 
> -	memset(dev->broadcast, 0xff, ETH_ALEN);
> +	eth_broadcast_addr(dev->broadcast);
> 	dev->addr_len = ETH_ALEN;

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
