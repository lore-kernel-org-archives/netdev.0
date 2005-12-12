From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [-mm patch] ACX should select, not depend on FW_LOADER
Date: Mon, 12 Dec 2005 07:59:26 +0200
Message-ID: <200512120759.26814.vda@ilport.com.ua>
References: <20051211182901.GP23349@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751103AbVLLF74@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20051211182901.GP23349@stusta.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 11 December 2005 20:29, Adrian Bunk wrote:
> If a driver needs FW_LOADER, it should select this option, not depend on 
> it.
> 
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> --- linux-2.6.15-rc5-mm2-full/drivers/net/wireless/tiacx/Kconfig.old	2005-12-11 19:04:49.000000000 +0100
> +++ linux-2.6.15-rc5-mm2-full/drivers/net/wireless/tiacx/Kconfig	2005-12-11 19:05:08.000000000 +0100
> @@ -1,6 +1,7 @@
>  config ACX
>  	tristate "TI acx100/acx111 802.11b/g wireless chipsets"
> -	depends on NET_RADIO && EXPERIMENTAL && FW_LOADER && (USB || PCI)
> +	depends on NET_RADIO && EXPERIMENTAL && (USB || PCI)
> +	select FW_LOADER
>  	---help---
>  	A driver for 802.11b/g wireless cards based on
>  	Texas Instruments acx100 and acx111 chipsets.

Applied to acx, thanks!
--
vda
