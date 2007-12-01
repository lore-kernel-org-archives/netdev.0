From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Fixed the case when the card initialization
 fails on mtu change
Date: Sat, 01 Dec 2007 16:33:22 -0500
Message-ID: <4751D322.3030100@garzik.org>
References: <Pine.GSO.4.10.10711300143550.6586-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32843 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723AbXLAVd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:33:26 -0500
In-Reply-To: <Pine.GSO.4.10.10711300143550.6586-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> Fix the case when the card initialization fails on a mtu change and then 
> close is called (due to ifdown), which frees non existent rx buffers.
> - Returning appropriate error codes in init_nic function.
> - In s2io_close function s2io_card_down is called only when device is up.
> - In s2io_change_mtu function return value of s2io_card_up function
>   is checked and returned if it failed.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp patch_8/drivers/net/s2io.c patch_9/drivers/net/s2io.c
> --- patch_8/drivers/net/s2io.c	2007-11-20 23:31:57.000000000 +0530
> +++ patch_9/drivers/net/s2io.c	2007-11-20 23:13:24.000000000 +0530
> @@ -84,7 +84,7 @@
>  #include "s2io.h"
>  #include "s2io-regs.h"
>  
> -#define DRV_VERSION "2.0.26.8"
> +#define DRV_VERSION "2.0.26.9"
>  
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] = "Neterion";

applied patch to 2.6.24-rc, except for the above chunk, which failed


