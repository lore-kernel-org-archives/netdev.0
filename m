From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [POWERPC] iSeries: fix section mismatch in iseries_veth
Date: Tue, 05 Feb 2008 13:32:33 -0500
Message-ID: <47A8ABC1.9080008@pobox.com>
References: <20080205141940.c6ddb479.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, ppc-dev <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42443 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbYBEScu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 13:32:50 -0500
In-Reply-To: <20080205141940.c6ddb479.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell wrote:
> WARNING: vmlinux.o(.text+0x25dca0): Section mismatch in reference from the function .veth_probe() to the function .init.text:.veth_probe_one()
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/iseries_veth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> Jeff, can this go in through the powerpc tree?
> 
> diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
> index 419861c..58d3bb6 100644
> --- a/drivers/net/iseries_veth.c
> +++ b/drivers/net/iseries_veth.c
> @@ -1020,7 +1020,7 @@ static const struct ethtool_ops ops = {
>  	.get_link = veth_get_link,
>  };
>  
> -static struct net_device * __init veth_probe_one(int vlan,
> +static struct net_device *veth_probe_one(int vlan,
>  		struct vio_dev *vio_dev)
>  {


it's trivial enough to not matter, and faster to just...  applied
(if you'll pardon the bad grammar)

