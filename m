From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH] net: add missing descriptions in net_device_priv_flags
Date: Mon, 21 Mar 2016 13:41:58 -0700
Message-ID: <20160321204158.GA6454@f1.synalogic.ca>
References: <1458591608-1088-1-git-send-email-luisbg@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Luis de Bethencourt <luisbg@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458591608-1088-1-git-send-email-luisbg@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/03/21 20:20, Luis de Bethencourt wrote:
> The flags IFF_XMIT_DST_RELEASE_PERM, IFF_IPVLAN_MASTER and
> IFF_IPVLAN_SLAVE are missing descriptions for the Documentation. Adding
> them.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
> ---
> Hi,
> 
> I also noticed this issue when running make htmldocs. Having better
> documentation is great :)
> 
> Thanks,
> Luis
> 
>  include/linux/netdevice.h | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index be693b3..db9ffe4 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1320,6 +1320,9 @@ struct net_device_ops {
>   * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
>   *	change when it's running
>   * @IFF_MACVLAN: Macvlan device
> + * @IFF_XMIT_DST_RELEASE_PERM: permanent IFF_XMIT_DST_RELEASE

I also noticed these kernel-doc warnings and had some patches queued for
them. May I suggest the following in this case:

 * @IFF_XMIT_DST_RELEASE_PERM: IFF_XMIT_DST_RELEASE not taking into account
 * 	underlying stacked devices

I presume that a patch for netdev ptype lists is forthcoming. Here's
what I had:

 *	@ptype_all:     Device-specific packet handlers for all protocols
 *	@ptype_specific: Device-specific, protocol-specific packet handlers

> + * @IFF_IPVLAN_MASTER: IPvlan master device
> + * @IFF_IPVLAN_SLAVE: IPvlan slave device
>   * @IFF_L3MDEV_MASTER: device is an L3 master device
>   * @IFF_NO_QUEUE: device can run without qdisc attached
>   * @IFF_OPENVSWITCH: device is a Open vSwitch master
> -- 
> 2.5.1
> 
