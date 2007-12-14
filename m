From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/sis190.c section fix
Date: Fri, 14 Dec 2007 15:27:50 -0500
Message-ID: <4762E746.8050405@pobox.com>
References: <20071211222356.GA14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43009 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047AbXLNU1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 15:27:54 -0500
In-Reply-To: <20071211222356.GA14204@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch fixes the following section mismatch with CONFIG_HOTPLUG=n:
> 
> <--  snip  -->
> 
> ...
> WARNING: vmlinux.o(.init.text.20+0x4cb25): Section mismatch: reference to .exit.text:sis190_mii_remove (between 'sis190_init_one' and 'read_eeprom')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 29fae057ba15a552a7cad1e731d3238d567032ba 
> diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
> index 7200883..49f767b 100644
> --- a/drivers/net/sis190.c
> +++ b/drivers/net/sis190.c
> @@ -1381,7 +1381,7 @@ out:
>  	return rc;
>  }
>  
> -static void __devexit sis190_mii_remove(struct net_device *dev)
> +static void sis190_mii_remove(struct net_device *dev)
>  {
>  	struct sis190_private *tp = netdev_priv(dev);
>  
> 

applied #upstream-fixes


