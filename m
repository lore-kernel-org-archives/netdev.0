From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation offload
 support
Date: Mon, 24 Oct 2005 11:00:03 -0700
Message-ID: <20051024110003.53e37edd@dxpl.pdx.osdl.net>
References: <432D7354.8000503@colorfullife.com>
	<43595C42.4080201@pobox.com>
	<435D1047.2070401@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Manfred Spraul
 <manfred@colorfullife.com>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <435D1047.2070401@nvidia.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Oct 2005 12:48:07 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> Jeff,
> 
> I made the changes you requested. Here is the new patch.
> 
> Thanks,
> Ayaz
> 
> Signed-off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 

> @@ -542,7 +545,7 @@
>  
>  static inline u8 __iomem *get_hwbase(struct net_device *dev)
>  {
> -	return get_nvpriv(dev)->base;
> +  return ((struct fe_priv *)netdev_priv(dev))->base;
>  }

Indentation?
Did you mean to leave the tab there.

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
