From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 14/20][BNX2]: Re-structure the 2.5G Serdes code.
Date: Wed, 02 May 2007 03:14:47 -0400
Message-ID: <46383A67.8050407@garzik.org>
References: <1178068571.4820.50.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56079 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbXEBHOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:14:50 -0400
In-Reply-To: <1178068571.4820.50.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c6310ae..f2d248f 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -434,6 +434,7 @@ struct ethtool_ops {
>  #define SUPPORTED_10000baseT_Full	(1 << 12)
>  #define SUPPORTED_Pause			(1 << 13)
>  #define SUPPORTED_Asym_Pause		(1 << 14)
> +#define SUPPORTED_2500baseX_Full	(1 << 15)
>  
>  /* Indicates what features are advertised by the interface. */
>  #define ADVERTISED_10baseT_Half		(1 << 0)
> @@ -451,6 +452,7 @@ struct ethtool_ops {
>  #define ADVERTISED_10000baseT_Full	(1 << 12)
>  #define ADVERTISED_Pause		(1 << 13)
>  #define ADVERTISED_Asym_Pause		(1 << 14)
> +#define ADVERTISED_2500baseX_Full	(1 << 15)


Please don't sneak in ethtool userspace API changes like this.  NAK.

The normal procedure for doing something like this is to create a 
separate patch and post it on netdev.  HOPEFULLY with the associated 
change to the ethtool(8) utility, to keep it in sync with the kernel. 
Otherwise, adding the above definition is useless to most users.  See 
http://sf.net/projects/gkernel/ or 
git://git.kernel.org/pub/scm/network/ethtool/ethtool.git for ethtool 
source code.

I ACK the changes to bnx2 outside of this, though.



