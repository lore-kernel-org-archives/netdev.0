From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH] net:Kconfig: drop no sense dependence entry for BONDING
Date: Thu, 12 Mar 2015 15:13:01 +0100
Message-ID: <20150312141301.GM306@haze>
References: <20150312135933.GA3502@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Wang YanQing <udknight@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-kbuild@vger.kernel.org>, <j.vosburgh@gmail.com>,
	<vfalico@gmail.com>, <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:59741 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbbCLOQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:16:19 -0400
Content-Disposition: inline
In-Reply-To: <20150312135933.GA3502@udknight>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 09:59:33PM +0800, Wang YanQing wrote:
> "IPV6 || IPV6=n" means no dependence!

Wow, this is all over the place..
find . -name 'Kconfig' | xargs grep 'depends on' |grep 'IPV6 || IPV6=n'

> 
> Signed-off-by: Wang YanQing <udknight@gmail.com>
> ---
>  drivers/net/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index df51d60..37b364f 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -40,7 +40,6 @@ if NET_CORE
>  config BONDING
>  	tristate "Bonding driver support"
>  	depends on INET
> -	depends on IPV6 || IPV6=n
>  	---help---
>  	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
>  	  Channels together. This is called 'Etherchannel' by Cisco,
> -- 
> 2.2.2.dirty
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
